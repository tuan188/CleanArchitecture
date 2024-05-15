//
//  ReposViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import UIKit

class ReposViewModel: GetRepoList, ShowRepoDetail {
    var repoGateway: RepoGatewayProtocol
    
    init(repoGateway: RepoGatewayProtocol) {
        self.repoGateway = repoGateway
    }
    
    // MARK: - Use cases
    
    func getRepos(page: Int) -> Observable<PagingInfo<Repo>> {
        let dto = GetPageDto(page: page, perPage: 10, usingCache: true)
        return getRepos(dto: dto)
    }
    
    // // MARK: - Navigation
    
    func vmShowRepoDetail(repo: Repo) {
        showRepoDetail(repo: repo)
    }
}

// MARK: - ViewModel
extension ReposViewModel: ObservableObject, ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
        let loadMoreTrigger: Driver<Void>
        let selectRepoTrigger: Driver<IndexPath>
    }
    
    final class Output: ObservableObject {
        @Published var repos = [RepoItemViewModel]()
        @Published var isLoading = false
        @Published var isReloading = false
        @Published var isLoadingMore = false
        @Published var alert = AlertMessage()
        @Published var isEmpty = false
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        
        let getPageInput = GetPageInput(loadTrigger: input.loadTrigger,
                                        reloadTrigger: input.reloadTrigger,
                                        loadMoreTrigger: input.loadMoreTrigger,
                                        getItems: getRepos)
        
        let (page, error, isLoading, isReloading, isLoadingMore) = getPage(input: getPageInput).destructured

        page
            .map { $0.items.map(RepoItemViewModel.init) }
            .assign(to: \.repos, on: output)
            .store(in: cancelBag)
        
        input.selectRepoTrigger
            .handleEvents(receiveOutput: { [unowned self] indexPath in
                let repo = getPageInput.pageSubject.value.items[indexPath.row]
                self.vmShowRepoDetail(repo: repo)
            })
            .sink()
            .store(in: cancelBag)
        
        error
            .receive(on: RunLoop.main)
            .map { AlertMessage(error: $0) }
            .assign(to: \.alert, on: output)
            .store(in: cancelBag)
        
        isLoading
            .assign(to: \.isLoading, on: output)
            .store(in: cancelBag)
        
        isReloading
            .assign(to: \.isReloading, on: output)
            .store(in: cancelBag)
        
        isLoadingMore
            .assign(to: \.isLoadingMore, on: output)
            .store(in: cancelBag)
        
        return output
    }
}
