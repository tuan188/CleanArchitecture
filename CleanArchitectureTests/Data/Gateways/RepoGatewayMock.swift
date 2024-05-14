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
    func getRepos(dto: GetPageDto) -> Observable<PagingInfo<Repo>> {
        fatalError()
    }
}

final class RepoGatewayFake: RepoGatewayProtocol {
    func getRepos(dto: GetPageDto) -> Observable<PagingInfo<Repo>> {
        fatalError()
    }
}
