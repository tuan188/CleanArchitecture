//
//  ValidationResult+.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/6/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Validator

extension ValidationResult {
    var message: String {
        switch self {
        case .valid:
            return ""
        case .invalid(let errors):
            return errors.map { $0.message }.joined(separator: "\n")
        }
    }
}
