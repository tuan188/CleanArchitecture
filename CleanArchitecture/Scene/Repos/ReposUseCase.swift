//
//  ReposUseCase.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol ReposUseCaseType {
    func getRepos(page: Int) -> Observable<PagingInfo<Repo>>
}

struct ReposUseCase: ReposUseCaseType, GettingRepos {
    let repoGateway: RepoGatewayType
    
    func getRepos(page: Int) -> Observable<PagingInfo<Repo>> {
        getRepos(page: page, perPage: 10, usingCache: false)
    }
}
