//
//  ReposViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import UIKit

struct ReposViewModel {
    let navigator: ReposNavigatorType
    let useCase: ReposUseCaseType
}

// MARK: - ViewModelType
extension ReposViewModel: ViewModel {
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
                                        getItems: useCase.getRepos)
        
        let (page, error, isLoading, isReloading, isLoadingMore) = getPage(input: getPageInput).destructured

        page
            .map { $0.items.map(RepoItemViewModel.init) }
            .assign(to: \.repos, on: output)
            .store(in: cancelBag)
        
        input.selectRepoTrigger
            .handleEvents(receiveOutput: { indexPath in
                let repo = getPageInput.pageSubject.value.items[indexPath.row]
                self.navigator.toRepoDetail(repo: repo)
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
