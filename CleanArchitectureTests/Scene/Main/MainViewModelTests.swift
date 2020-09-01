//
//  MainViewModelTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import Combine

final class MainViewModelTests: XCTestCase {
    private var viewModel: MainViewModel!
    private var navigator: MainNavigatorMock!
    private var useCase: MainUseCaseMock!
    
    private var input: MainViewModel.Input!
    private var output: MainViewModel.Output!
    private var cancelBag: CancelBag!
    
    private let loadTrigger = PassthroughSubject<Void, Never>()
    private let selectMenuTrigger = PassthroughSubject<IndexPath, Never>()
    
    override func setUp() {
        super.setUp()
        navigator = MainNavigatorMock()
        useCase = MainUseCaseMock()
        viewModel = MainViewModel(navigator: navigator, useCase: useCase)
        cancelBag = CancelBag()
        
        input = MainViewModel.Input(loadTrigger: loadTrigger.asDriver(),
                                    selectMenuTrigger: selectMenuTrigger.asDriver())
        output = viewModel.transform(input, cancelBag: cancelBag)
    }
    
    func test_load_menu() {
        // act
        loadTrigger.send(())
        
        // assert
        wait {
            XCTAssertEqual(self.output.menuSections.count, 3)
        }
    }
    
    func test_selectMenu_toProducts() {
        // act
        loadTrigger.send(())
        selectMenuTrigger.send(IndexPath(row: 0, section: 0))
        
        // assert
        wait {
            XCTAssert(self.navigator.toProductsCalled)
        }
    }
}
