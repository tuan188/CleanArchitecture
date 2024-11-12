//
//  LogIn.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import Foundation

protocol LogIn {
    var authGateway: AuthGatewayProtocol { get }
}

extension LogIn {
    func login(username: String, password: String) -> AnyPublisher<Void, Error> {
        authGateway.login(username: username, password: username)
    }
    
    func validateUserName(_ userName: String) -> ValidationResult {
        if userName.isEmpty {
            return .failure(.init(message: "You must provide a name"))
        }
        
        return .success(())
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .failure(.init(message: "You must provide a password"))
        }
        
        return .success(())
    }
}
