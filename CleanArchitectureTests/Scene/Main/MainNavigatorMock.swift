//
//  MainNavigatorMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture

final class MainNavigatorMock: MainNavigatorType {
    
    // MARK: - toProducts
    
    var toProductsCalled = false
    
    func toProducts() {
        toProductsCalled = true
    }
    
    // MARK: - toSectionedProducts
    
    var toSectionedProductsCalled = false
    
    func toSectionedProducts() {
        toSectionedProductsCalled = true
    }
    
    // MARK: - toRepos
    
    var toReposCalled = false
    
    func toRepos() {
        toReposCalled = true
    }
    
    // MARK: - toRepoCollection
    
    var toRepoCollectionCalled = false
    
    func toRepoCollection() {
        toRepoCollectionCalled = true
    }
    
    // MARK: - toUsers
    
    var toUsersCalled = false
    
    func toUsers() {
        toUsersCalled = true
    }
    
    // MARK: - toLogin
    
    var toLoginCalled = false
    
    func toLogin() {
        toLoginCalled = true
    }
}
