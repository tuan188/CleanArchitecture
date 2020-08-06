//
//  UserValidationError.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/6/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Validator

enum UserValidationError: ValidationError {
    case usernameMinLength
    case passwordMinLength
    
    var message: String {
        switch self {
        case .usernameMinLength:
            return "Please enter your username."
        case .passwordMinLength:
            return "Please enter your password"
        }
    }
}
