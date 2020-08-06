//
//  ValidatingUserName.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/6/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Validator

protocol ValidatingUserName {
    
}

extension ValidatingUserName {
    func validateUserName(_ username: String) -> ValidationResult {
        let minLengthRule = ValidationRuleLength(min: 1, error: UserValidationError.usernameMinLength)
        return username.validate(rule: minLengthRule)
    }
}
