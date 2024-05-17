//
//  AuthGatewayMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/11/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import UIKit
import Combine

final class AuthGatewayMock: AuthGatewayProtocol {
    
    // MARK: - login
    
    var loginCalled = false
    var loginReturnValue: Result<Void, Error> = .success(())
    
    func login(dto: LoginDto) -> AnyPublisher<Void, Error> {
        loginCalled = true
        return loginReturnValue.publisher.eraseToAnyPublisher()
    }
}
