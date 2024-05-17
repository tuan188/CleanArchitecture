//
//  RepoGatewayMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 14/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import UIKit
import Combine

final class RepoGatewayMock: RepoGatewayProtocol {
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        Just(PagingInfo<Repo>.fake).asObservable()
    }
}

final class RepoGatewayFake: RepoGatewayProtocol {
    // swiftlint:disable:next unavailable_function
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        fatalError("N/A")
    }
}
