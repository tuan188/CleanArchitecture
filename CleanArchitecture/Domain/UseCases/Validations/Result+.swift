//
//  Result+.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/1/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import ValidatedPropertyKit

extension Result where Failure == ValidationError {
    var message: String {
        switch self {
        case .success:
            return ""
        case .failure(let error):
            return error.description
        }
    }
    
    var isValid: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
