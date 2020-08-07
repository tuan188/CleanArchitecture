//
//  APIServiceBase.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/30/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import ObjectMapper
import Alamofire
import Combine
import UIKit

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
    
    open func request<T: Mappable>(_ input: APIInputBase) -> AnyPublisher<APIResponse<T>, Error> {
        let response: AnyPublisher<APIResponse<JSONDictionary>, Error> = requestJSON(input)
        
        return response
            .tryMap { apiResponse -> APIResponse<T> in
                if let t = T(JSON: apiResponse.data) {
                    return APIResponse(header: apiResponse.header, data: t)
                }
                
                throw APIInvalidResponseError()
            }
            .eraseToAnyPublisher()
    
    }
    
    open func request<T: Mappable>(_ input: APIInputBase) -> AnyPublisher<T, Error> {
        request(input)
            .map { $0.data }
            .eraseToAnyPublisher()
    }

    open func request<T: Mappable>(_ input: APIInputBase) -> AnyPublisher<APIResponse<[T]>, Error> {
        let response: AnyPublisher<APIResponse<JSONArray>, Error> = requestJSON(input)
        
        return response
            .map { apiResponse -> APIResponse<[T]> in
                return APIResponse(header: apiResponse.header,
                                   data: Mapper<T>().mapArray(JSONArray: apiResponse.data))
            }
            .eraseToAnyPublisher()
    }
    
    open func request<T: Mappable>(_ input: APIInputBase) -> AnyPublisher<[T], Error> {
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
                let request = self.manager.request(
                    input.urlString,
                    method: input.method,
                    parameters: input.parameters,
                    encoding: input.endcoding,
                    headers: input.headers
                )
                
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
                if input.useCache {
                    DispatchQueue.global().async {
                        try? CacheManager.sharedInstance.write(urlString: input.urlEncodingString,
                                                               data: response.data,
                                                               header: response.header)
                    }
                }
            })
            .eraseToAnyPublisher()
        
        return urlRequest
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
