//
//  AppViewModelTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import Combine

final class AppViewModelTests: XCTestCase {
    private var viewModel: AppViewModel!
    private var navigator: AppNavigatorMock!
    private var useCase: AppUseCaseMock!
    
    private var input: AppViewModel.Input!
    private var output: AppViewModel.Output!
    private var cancelBag: CancelBag!
    
    private var startTrigger = PassthroughSubject<Void, Never>()
    
    override func setUp() {
        super.setUp()
        navigator = AppNavigatorMock()
        useCase = AppUseCaseMock()
        viewModel = AppViewModel(navigator: navigator, useCase: useCase)
        
        input = AppViewModel.Input(startTrigger: startTrigger.asDriver())
        cancelBag = CancelBag()
        output = viewModel.transform(input, cancelBag: cancelBag)
    }
    
    func test_start_toMain() {
        // act
        startTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.navigator.toMainCalled)
        }
    }
}
