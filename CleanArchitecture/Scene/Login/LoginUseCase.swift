//
//  LoginUseCase.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Validator

protocol LoginUseCaseType {
    func validateUserName(_ username: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
    func login(username: String, password: String) -> Observable<Void>
}

struct LoginUseCase: LoginUseCaseType, LoggingIn, ValidatingUserName, ValidatingPassword {
    let authGateway: AuthGatewayType
}
