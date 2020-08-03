//
//  GettingRepos.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

protocol GettingRepos {
    var repoGateway: RepoGatewayType { get }
}

extension GettingRepos {
    func getRepos(page: Int, perPage: Int, usingCache: Bool) -> Observable<PagingInfo<Repo>> {
        repoGateway.getRepos(page: page, perPage: perPage, usingCache: usingCache)
    }
}
