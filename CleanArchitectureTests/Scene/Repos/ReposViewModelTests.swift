//
//  ReposViewModelTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 14/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import Combine

final class ReposViewModelTests: XCTestCase {
    private var viewModel: TestReposViewModel!
    private var cancelBag = CancelBag()
    private var output: ReposViewModel.Output!
    
    private var loadTrigger = PassthroughSubject<Void, Never>()
    private var reloadTrigger = PassthroughSubject<Void, Never>()
    private var loadMoreTrigger = PassthroughSubject<Void, Never>()
    private var selectRepoTrigger = PassthroughSubject<IndexPath, Never>()

    override func setUpWithError() throws {
        viewModel = TestReposViewModel()
        cancelBag = CancelBag()
        
        let input = ReposViewModel.Input(
            loadTrigger: loadTrigger.eraseToAnyPublisher(),
            reloadTrigger: reloadTrigger.eraseToAnyPublisher(),
            loadMoreTrigger: loadMoreTrigger.eraseToAnyPublisher(),
            selectRepoTrigger: selectRepoTrigger.eraseToAnyPublisher()
        )
        
        output = viewModel.transform(input, cancelBag: cancelBag)
    }
    
    func test_loadTrigger_getRepos() {
        // act
        loadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.viewModel.getReposCalled)
            XCTAssertEqual(self.output.repos.count, 1)
        }
    }
}

final class TestReposViewModel: ReposViewModel {
    var vmShowRepoDetailCalled = false
    var getReposCalled = false
    var getReposReturnValue: Result<PagingInfo<Repo>, Error> = .success(PagingInfo.fake)
    
    override func vm_showRepoDetail(repo: Repo) {
        vmShowRepoDetailCalled = true
    }
    
    override func getRepos(page: Int) -> AnyPublisher<PagingInfo<Repo>, Error> {
        getReposCalled = true
        return getReposReturnValue.publisher.eraseToAnyPublisher()
    }
}
