//
//  RepoGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import Foundation
import Factory
import APIService

protocol RepoGatewayProtocol {
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error>
}

struct RepoGateway: RepoGatewayProtocol {
    private struct GetReposResult: Decodable {
        var items = [Repo]()
    }
    
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        APIServices.default
            .request(GitEndpoint.repos(page: page, perPage: perPage))
            .data(type: GetReposResult.self)
            .map { $0.items }
            .map { PagingInfo(page: page, items: $0) }
            .eraseToAnyPublisher()
    }
}

struct PreviewRepoGateway: RepoGatewayProtocol {
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        Future<PagingInfo<Repo>, Error> { promise in
            let repos = [
                Repo(id: 0,
                     name: "SwiftUI",
                     fullname: "SwiftUI Framework",
                     urlString: "",
                     starCount: 10,
                     folkCount: 10,
                     owner: Repo.Owner(avatarUrl: ""))
            ]
            
            let page = PagingInfo<Repo>(page: 1, items: repos)
            promise(.success(page))
        }
        .eraseToAnyPublisher()
    }
}

extension Container {
    var repoGateway: Factory<RepoGatewayProtocol> {
        Factory(self) {
            RepoGateway()
        }
        .onPreview {
            PreviewRepoGateway()
        }
    }
}
