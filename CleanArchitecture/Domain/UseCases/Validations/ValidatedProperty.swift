//
//  ValidatedProperty.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/1/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import ValidatedPropertyKit

public protocol ValidatedProperty {
    var isValid: Bool { get }
    var validationError: ValidationError? { get }
}

extension Validated: ValidatedProperty { }
