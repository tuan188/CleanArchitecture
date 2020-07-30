//
//  APIService.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/31/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Alamofire
import Foundation

final class API: APIBase {
    static var shared = API()
    
    override func handleResponseError(dataResponse: DataResponse<Data, AFError>, json: JSONDictionary?) -> Error {
        if let json = json, let message = json["message"] as? String {
            return APIResponseError(statusCode: dataResponse.response?.statusCode, message: message)
        }
        return super.handleResponseError(dataResponse: dataResponse, json: json)
    }
}
