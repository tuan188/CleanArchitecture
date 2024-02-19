//
//  ReposViewControllerTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 01/02/2024.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

import XCTest
import Combine
@testable import CleanArchitecture

final class ReposViewControllerTests: XCTestCase {
    var vc: TestReposViewController!
    
    let loadTrigger = PassthroughSubject<Void, Never>()
    let reloadTrigger = PassthroughSubject<Void, Never>()
    let loadMoreTrigger = PassthroughSubject<Void, Never>()
    let selectRepoTrigger = PassthroughSubject<IndexPath, Never>()
    var cancelBag: CancelBag!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let input = TestReposViewController.Input(
            loadTrigger: Driver.just(()),
            reloadTrigger: reloadTrigger.asDriver(),
            loadMoreTrigger: loadMoreTrigger.asDriver(),
            selectRepoTrigger: selectRepoTrigger.asDriver()
        )
        cancelBag = CancelBag()
        vc = TestReposViewController()
        let output = vc.transform(input, cancelBag: cancelBag)

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_loadTrigger_getRepoList() {
        // act
        loadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.vc.getRepoListCalled)
//            XCTAssertEqual(self.output.products.count, 1)
        }
    }


}

class TestReposViewController: ReposViewController {
    var getRepoListCalled = false
    
    override func getRepos(dto: GetPageDto) -> Observable<PagingInfo<Repo>> {
        getRepoListCalled = true
        return .empty()
    }
}
