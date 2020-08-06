//
//  ValidatingPassword.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/6/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Validator

protocol ValidatingPassword {
    
}

extension ValidatingPassword {
    func validatePassword(_ password: String) -> ValidationResult {
        let minLengthRule = ValidationRuleLength(min: 1, error: UserValidationError.passwordMinLength)
        return password.validate(rule: minLengthRule)
    }
}
