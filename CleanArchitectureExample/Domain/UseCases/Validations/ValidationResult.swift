//
//  ValidationResult.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 17/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

import Foundation

typealias ValidationResult = Result<Void, ValidationError>

extension Result where Failure == ValidationError {
    var message: String? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error.localizedDescription
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
    
    func mapToVoid() -> ValidationResult {
        return self.map { _ in () }
    }
}

