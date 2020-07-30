//
//  APIResponse.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/30/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

public struct APIResponse<T> {
    public var header: ResponseHeader?
    public var data: T
    
    public init(header: ResponseHeader?, data: T) {
        self.header = header
        self.data = data
    }
}
