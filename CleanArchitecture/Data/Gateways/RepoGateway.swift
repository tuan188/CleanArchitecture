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

protocol RepoGatewayProtocol {
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error>
}

struct RepoGateway: RepoGatewayProtocol {
    func getRepos(page: Int, perPage: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        let input = API.GetRepoListInput(page: page, perPage: perPage)
        
        return API.shared.getRepoList(input)
            .map { (output) -> [Repo]? in
                return output.repos
            }
            .replaceNil(with: [])
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
    }
    
    var previewRepoGateway: Factory<RepoGatewayProtocol> {
        Factory(self) {
            PreviewRepoGateway()
        }
    }
}
