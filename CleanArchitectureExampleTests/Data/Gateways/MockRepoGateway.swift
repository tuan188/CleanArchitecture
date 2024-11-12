//
//  MockRepoGateway.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 14/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

@testable import CleanArchitectureExample
import UIKit
import Combine
import CleanArchitecture

final class MockRepoGateway: RepoGatewayProtocol {
    var getReposCalled = false
    var getReposResult: Result<PagingInfo<Repo>, Error> = .success(PagingInfo<Repo>.fake)
    
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        getReposCalled = true
        return getReposResult.publisher.eraseToAnyPublisher()
    }
}

final class RepoGatewayFake: RepoGatewayProtocol {
    // swiftlint:disable:next unavailable_function
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        fatalError("N/A")
    }
}
