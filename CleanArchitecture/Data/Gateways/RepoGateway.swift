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
    func getRepos(dto: GetPageDto) -> Observable<PagingInfo<Repo>>
}

struct RepoGateway: RepoGatewayProtocol {
    func getRepos(dto: GetPageDto) -> Observable<PagingInfo<Repo>> {
        let input = API.GetRepoListInput(dto: dto)
        
        return API.shared.getRepoList(input)
            .map { (output) -> [Repo]? in
                return output.repos
            }
            .replaceNil(with: [])
            .map { PagingInfo(page: dto.page, items: $0) }
            .eraseToAnyPublisher()
    }
}

struct PreviewRepoGateway: RepoGatewayProtocol {
    func getRepos(dto: GetPageDto) -> Observable<PagingInfo<Repo>> {
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
