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
