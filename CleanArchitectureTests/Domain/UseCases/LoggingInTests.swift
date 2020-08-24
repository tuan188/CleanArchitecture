//
//  LoggingInTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/11/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import XCTest

final class LoggingInTests: XCTestCase, LoggingIn {
    var authGateway: AuthGatewayType {
        return authGatewayMock
    }
    
    private var authGatewayMock = AuthGatewayMock()
    private var cancelBag: CancelBag!

    override func setUpWithError() throws {
        cancelBag = CancelBag()
    }
    
    func test_login() {
        let result = expectValue(of: self.login(dto: LoginDto(username: "username", password: "password")),
                                 equals: [ { _ in true } ])
        wait(for: [result.expectation], timeout: 1)
    }
    
    func test_login_failed() {
        authGatewayMock.loginReturnValue = .failure(TestError())
        
        let result = expectFailure(of: self.login(dto: LoginDto()))
        wait(for: [result.expectation], timeout: 1)
    }
}
