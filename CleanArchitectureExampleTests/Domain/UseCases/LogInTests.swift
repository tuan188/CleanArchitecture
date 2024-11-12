//
//  LogInTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/11/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitectureExample
import XCTest
import CleanArchitecture

final class LogInTests: XCTestCase, LogIn {
    var authGateway: AuthGatewayProtocol {
        return authGatewayMock
    }
    
    private var authGatewayMock = MockAuthGateway()
    private var cancelBag: CancelBag!

    override func setUpWithError() throws {
        cancelBag = CancelBag()
    }
    
    func test_login() {
        let result = expectValue(of: self.login(username: "username", password: "password"),
                                 equals: [ { _ in true } ])
        wait(for: [result.expectation], timeout: 1)
    }
    
    func test_login_failed() {
        authGatewayMock.loginReturnValue = .failure(TestError())
        
        let result = expectFailure(of: self.login(username: "user", password: "password"))
        wait(for: [result.expectation], timeout: 1)
    }
}
