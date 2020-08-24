//
//  GettingRepos.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

struct GetReposDto {
    var page = 1
    var perPage = 10
    var usingCache = false
}

protocol GettingRepos {
    var repoGateway: RepoGatewayType { get }
}

extension GettingRepos {
    func getRepos(_ dto: GetReposDto) -> Observable<PagingInfo<Repo>> {
        repoGateway.getRepos(dto)
    }
}
