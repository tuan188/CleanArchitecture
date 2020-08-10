//
//  AppNavigatorMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture

final class AppNavigatorMock: AppNavigatorType {
    
    // MARK: - toMain
    
    var toMainCalled = false
    
    func toMain() {
        toMainCalled = true
    }
}
