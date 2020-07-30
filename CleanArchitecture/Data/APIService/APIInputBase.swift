//
//  APIInputBase.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/30/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Alamofire
import Foundation

open class APIInputBase {
    public var headers: [String: String] = [:]
    public var urlString: String
    public var requestType: HTTPMethod
    public var encoding: ParameterEncoding
    public var parameters: [String: Any]?
    public var requireAccessToken: Bool
    public var accessToken: String?
    
    public var useCache: Bool = false {
        didSet {
            if requestType != .get || self is APIUploadInputBase {
                fatalError()  // swiftlint:disable:this fatal_error_message
            }
        }
    }
    
    public var username: String?
    public var password: String?
    
    public init(urlString: String,
                parameters: [String: Any]?,
                requestType: HTTPMethod,
                requireAccessToken: Bool) {
        self.urlString = urlString
        self.parameters = parameters
        self.requestType = requestType
        self.encoding = requestType == .get ? URLEncoding.default : JSONEncoding.default
        self.requireAccessToken = requireAccessToken
    }
}

extension APIInputBase {
    open var urlEncodingString: String {
        guard
            let url = URL(string: urlString),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let parameters = parameters,
            requestType == .get
            else {
                return urlString
        }
        
        urlComponents.queryItems = []
        
        for name in parameters.keys.sorted() {
            if let value = parameters[name] {
                let item = URLQueryItem(
                    name: "\(name)",
                    value: "\(value)"
                )
                
                urlComponents.queryItems?.append(item)
            }
        }
        
        return urlComponents.url?.absoluteString ?? urlString
    }
    
    open func description(isIncludedParameters: Bool) -> String {
        if requestType == .get || !isIncludedParameters {
            return "🌎 \(requestType.rawValue) \(urlEncodingString)"
        }
        
        return [
            "🌎 \(requestType.rawValue) \(urlString)",
            "Parameters: \(String(describing: parameters ?? JSONDictionary()))"
        ]
        .joined(separator: "\n")
    }
}

public struct APIUploadData {
    public let data: Data
    public let name: String
    public let fileName: String
    public let mimeType: String
    
    public init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

open class APIUploadInputBase: APIInputBase {
    public let data: [APIUploadData]
    
    public init(data: [APIUploadData],
                urlString: String,
                parameters: [String: Any]?,
                requestType: HTTPMethod,
                requireAccessToken: Bool) {
        
        self.data = data
        
        super.init(
            urlString: urlString,
            parameters: parameters,
            requestType: requestType,
            requireAccessToken: requireAccessToken
        )
    }
}
