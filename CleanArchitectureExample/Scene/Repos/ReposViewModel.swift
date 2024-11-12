//
//  ReposViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import UIKit
import Factory

class ReposViewModel: GetRepoList, ShowRepoDetail { // swiftlint:disable:this final_class
    @Injected(\.repoGateway) 
    var repoGateway: RepoGatewayProtocol
    
    // MARK: - Use cases
    
    func getRepos(page: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        return getRepos(page: page, perPage: 10)
    }
    
    // // MARK: - Navigation
    
    func vm_showRepoDetail(repo: Repo) {
        showRepoDetail(repo: repo)
    }
    
    deinit {
        print("ReposViewModel deinit")
    }
}

// MARK: - ViewModel
extension ReposViewModel: ObservableObject, ViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
        let reloadTrigger: AnyPublisher<Void, Never>
        let loadMoreTrigger: AnyPublisher<Void, Never>
        let selectRepoTrigger: AnyPublisher<IndexPath, Never>
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
        
        let config = PageFetchConfig(initialLoadTrigger: input.loadTrigger,
                                     reloadTrigger: input.reloadTrigger,
                                     loadMoreTrigger: input.loadMoreTrigger,
                                     fetchItems: getRepos)
        
        let (page, error, isLoading, isReloading, isLoadingMore) = fetchPage(config: config).destructured

        page
            .map { $0.items.map(RepoItemViewModel.init) }
            .assign(to: \.repos, on: output)
            .store(in: cancelBag)
        
        input.selectRepoTrigger
            .handleEvents(receiveOutput: { indexPath in
                let repo = config.pageSubject.value.items[indexPath.row]
                self.vm_showRepoDetail(repo: repo)
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
