//
//  Dto.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/24/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import ValidatedPropertyKit

public protocol Dto {
    var validatedProperties: [ValidatedProperty] { get }
}

extension Dto {
    var isValid: Bool {
        return validatedProperties.allSatisfy { $0.isValid }
    }
    
    var validationErrors: [ValidationError] {
        return validatedProperties.compactMap { $0.validationError }
    }
    
    var validationErrorMessages: [String] {
        return validationErrors.map { $0.description }
    }
    
    var validationError: ValidationError? {
        if isValid { return nil }
        return ValidationError(messages: validationErrorMessages)
    }
}

public protocol ValidatedProperty {
    var isValid: Bool { get }
    var validationError: ValidationError? { get }
}

extension Validated: ValidatedProperty { }

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

public extension Validation where Value: Collection {
    
    /// The non empty Validation with error message
    static func nonEmpty(message: String) -> Validation {
        return .init { value in
            if !value.isEmpty {
                return .success(())
            } else {
                return .failure(ValidationError(message: message))
            }
        }
    }
}
