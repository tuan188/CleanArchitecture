//
//  APIServiceBase.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/30/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Alamofire
import Combine
import UIKit
import Foundation

public typealias JSONDictionary = [String: Any]
public typealias JSONArray = [JSONDictionary]
public typealias ResponseHeader = [AnyHashable: Any]

public protocol JSONData {
    init()
    static func equal(left: JSONData, right: JSONData) -> Bool
}

extension JSONDictionary: JSONData {
    public static func equal(left: JSONData, right: JSONData) -> Bool {
        // swiftlint:disable:next force_cast
        NSDictionary(dictionary: left as! JSONDictionary).isEqual(to: right as! JSONDictionary)
    }
}

extension JSONArray: JSONData {
    public static func equal(left: JSONData, right: JSONData) -> Bool {
        let leftArray = left as! JSONArray  // swiftlint:disable:this force_cast
        let rightArray = right as! JSONArray  // swiftlint:disable:this force_cast
        
        guard leftArray.count == rightArray.count else { return false }
        
        for i in 0..<leftArray.count {
            if !JSONDictionary.equal(left: leftArray[i], right: rightArray[i]) {
                return false
            }
        }
        
        return true
    }
}

open class APIBase {
    
    public var manager: Alamofire.Session
    public var logOptions = LogOptions.default
    
    public convenience init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        
        self.init(configuration: configuration)
    }
    
    public init(configuration: URLSessionConfiguration) {
        manager = Alamofire.Session(configuration: configuration)
    }
    
    open func request<T: Decodable>(_ input: APIInputBase) -> AnyPublisher<APIResponse<T>, Error> {
        let response: AnyPublisher<APIResponse<JSONDictionary>, Error> = requestJSON(input)
        
        return response
            .tryMap { apiResponse -> APIResponse<T> in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: apiResponse.data,
                                                              options: .prettyPrinted)
                    let t = try JSONDecoder().decode(T.self, from: jsonData)
                    return APIResponse(header: apiResponse.header, data: t)
                } catch {
                    throw APIInvalidResponseError()
                }
            }
            .eraseToAnyPublisher()
    }
    
    open func request<T: Decodable>(_ input: APIInputBase) -> AnyPublisher<T, Error> {
        request(input)
            .map { $0.data }
            .eraseToAnyPublisher()
    }

    open func request<T: Codable>(_ input: APIInputBase) -> AnyPublisher<APIResponse<[T]>, Error> {
        let response: AnyPublisher<APIResponse<JSONArray>, Error> = requestJSON(input)

        return response
            .tryMap { apiResponse -> APIResponse<[T]> in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: apiResponse.data,
                                                              options: .prettyPrinted)

                    let items = try JSONDecoder().decode([T].self, from: jsonData)
                    return APIResponse(header: apiResponse.header,
                                       data: items)
                } catch {
                    throw APIInvalidResponseError()
                }
            }
            .eraseToAnyPublisher()
    }
    
    open func request<T: Decodable>(_ input: APIInputBase) -> AnyPublisher<[T], Error> {
        request(input)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
    
    open func requestJSON<U: JSONData>(_ input: APIInputBase) -> AnyPublisher<APIResponse<U>, Error> {
        let username = input.username
        let password = input.password
        
        let urlRequest = preprocess(input)
            .handleEvents(receiveOutput: { [unowned self] input in
                if self.logOptions.contains(.request) {
                    print(input.description(isIncludedParameters: self.logOptions.contains(.requestParameters)))
                }
            })
            .map { [unowned self] input -> DataRequest in
                let request: DataRequest
                
                if let uploadInput = input as? APIUploadInputBase {
                    request = self.manager.upload(
                        multipartFormData: { (multipartFormData) in
                            input.parameters?.forEach { key, value in
                                if let data = String(describing: value).data(using: .utf8) {
                                    multipartFormData.append(data, withName: key)
                                }
                            }
                            uploadInput.data.forEach({
                                multipartFormData.append(
                                    $0.data,
                                    withName: $0.name,
                                    fileName: $0.fileName,
                                    mimeType: $0.mimeType)
                            })
                        },
                        to: uploadInput.urlString,
                        method: uploadInput.method,
                        headers: uploadInput.headers
                    )
                } else {
                    request = self.manager.request(
                        input.urlString,
                        method: input.method,
                        parameters: input.parameters,
                        encoding: input.encoding,
                        headers: input.headers
                    )
                }
                
                if let username = username, let password = password {
                    return request.authenticate(username: username, password: password)
                }
                return request
            }
            .handleEvents(receiveOutput: { (dataRequest) in
                if self.logOptions.contains(.rawRequest) {
                    debugPrint(dataRequest)
                }
            })
            .flatMap { dataRequest -> AnyPublisher<DataResponse<Data, AFError>, Error> in
                return dataRequest.publishData()
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .tryMap { (dataResponse) -> APIResponse<U> in
                return try self.process(dataResponse)
            }
            .tryCatch { [unowned self] error -> AnyPublisher<APIResponse<U>, Error> in
                return try self.handleRequestError(error, input: input)
            }
            .handleEvents(receiveOutput: { response in
                if input.usingCache {
                    DispatchQueue.global().async {
                        try? CacheManager.sharedInstance.write(urlString: input.urlEncodingString,
                                                               data: response.data,
                                                               header: response.header)
                    }
                }
            })
            .eraseToAnyPublisher()
        
        let cacheRequest: AnyPublisher<APIResponse<U>, Error> = Just(input)
            .setFailureType(to: Error.self)
            .filter { $0.usingCache }
            .tryMap { input -> (Any, ResponseHeader?) in
                return try CacheManager.sharedInstance.read(urlString: input.urlEncodingString)
            }
            .catch { _ in Empty() }
            .filter { $0.0 is U }
            .map { data, header -> APIResponse<U> in
                APIResponse(header: header, data: data as! U) // swiftlint:disable:this force_cast
            }
            .handleEvents(receiveOutput: { [unowned self] response in
                if self.logOptions.contains(.cache) {
                    print("[CACHE]")
                    print(response.data)
                }
            })
            .eraseToAnyPublisher()
        
        return input.usingCache
            ? Publishers.Concatenate(prefix: cacheRequest, suffix: urlRequest)
                .eraseToAnyPublisher()
            : urlRequest
    }
    
    open func preprocess(_ input: APIInputBase) -> AnyPublisher<APIInputBase, Error> {
        Just(input)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    open func process<U: JSONData>(_ dataResponse: DataResponse<Data, AFError>) throws -> APIResponse<U> {
        let error: Error
        
        switch dataResponse.result {
        case .success(let data):
            let json: U? = (try? JSONSerialization.jsonObject(with: data, options: [])) as? U
            
            guard let statusCode = dataResponse.response?.statusCode else {
                throw APIUnknownError(statusCode: nil)
            }
            
            switch statusCode {
            case 200..<300:
                if logOptions.contains(.responseStatus) {
                    print("👍 [\(statusCode)] " + (dataResponse.response?.url?.absoluteString ?? ""))
                }
                
                if logOptions.contains(.dataResponse) {
                    print(dataResponse)
                }
                
                if logOptions.contains(.responseData) {
                    print("[RESPONSE DATA]")
                    print(json ?? data)
                }
                
                // swiftlint:disable:next explicit_init
                return APIResponse(header: dataResponse.response?.allHeaderFields, data: json ?? U.init())
            default:
                error = handleResponseError(dataResponse: dataResponse, json: json)
                
                if logOptions.contains(.responseStatus) {
                    print("❌ [\(statusCode)] " + (dataResponse.response?.url?.absoluteString ?? ""))
                }
                
                if logOptions.contains(.dataResponse) {
                    print(dataResponse)
                }
                
                if logOptions.contains(.error) || logOptions.contains(.responseData) {
                    print("[RESPONSE DATA]")
                    print(json ?? data)
                }
            }
            
        case .failure(let afError):
            error = afError
        }
        
        throw error
    }
    
    open func handleRequestError<U: JSONData>(_ error: Error,
                                              input: APIInputBase) throws -> AnyPublisher<APIResponse<U>, Error> {
        throw error
    }
    
    open func handleResponseError<U: JSONData>(dataResponse: DataResponse<Data, AFError>, json: U?) -> Error {
        if let jsonDictionary = json as? JSONDictionary {
            return handleResponseError(dataResponse: dataResponse, json: jsonDictionary)
        } else if let jsonArray = json as? JSONArray {
            return handleResponseError(dataResponse: dataResponse, json: jsonArray)
        }
        
        return handleResponseUnknownError(dataResponse: dataResponse)
    }
    
    open func handleResponseError(dataResponse: DataResponse<Data, AFError>, json: JSONDictionary?) -> Error {
        APIUnknownError(statusCode: dataResponse.response?.statusCode)
    }
    
    open func handleResponseError(dataResponse: DataResponse<Data, AFError>, json: JSONArray?) -> Error {
        APIUnknownError(statusCode: dataResponse.response?.statusCode)
    }
    
    open func handleResponseUnknownError(dataResponse: DataResponse<Data, AFError>) -> Error {
        APIUnknownError(statusCode: dataResponse.response?.statusCode)
    }
}
