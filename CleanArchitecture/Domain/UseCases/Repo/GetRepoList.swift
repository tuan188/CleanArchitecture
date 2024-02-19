//
//  GetRepoList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

protocol GetRepoList {
    var repoGateway: RepoGatewayProtocol { get }
}

extension GetRepoList {
    func getRepos(dto: GetPageDto) -> Observable<PagingInfo<Repo>> {
        repoGateway.getRepos(dto: dto)
    }
}
