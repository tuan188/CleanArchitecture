//
//  ProductsViewModelTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/11/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import Combine

final class ProductsViewModelTests: XCTestCase {
    private var viewModel: ProductsViewModel!
    private var navigator: ProductsNavigatorMock!
    private var useCase: ProductsUseCaseMock!
    
    private var input: ProductsViewModel.Input!
    private var output: ProductsViewModel.Output!
    private var loadTrigger = PassthroughSubject<Void, Never>()
    private var reloadTrigger = PassthroughSubject<Void, Never>()
    private var selectTrigger = PassthroughSubject<IndexPath, Never>()
    
    private var cancelBag: CancelBag!
    
    override func setUp() {
        super.setUp()
        navigator = ProductsNavigatorMock()
        useCase = ProductsUseCaseMock()
        viewModel = ProductsViewModel(navigator: navigator, useCase: useCase)
        
        input = ProductsViewModel.Input(loadTrigger: loadTrigger.eraseToAnyPublisher(),
                                        reloadTrigger: reloadTrigger.eraseToAnyPublisher(),
                                        selectTrigger: selectTrigger.eraseToAnyPublisher())
        
        cancelBag = CancelBag()
        output = viewModel.transform(input, cancelBag: cancelBag)
    }
    
    func test_loadTrigger_getProducts() {
        // act
        loadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.useCase.getProductsCalled)
            XCTAssertEqual(self.output.products.count, 1)
        }
    }
    
    func test_loadTrigger_failed_showError() {
        // arrange
        useCase.getProductsReturnValue = .failure(TestError())
        
        // act
        loadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.useCase.getProductsCalled)
            XCTAssert(self.output.alert.isShowing)
        }
    }
    
    func test_reloadTrigger_getProducts() {
        // act
        reloadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.useCase.getProductsCalled)
            XCTAssertEqual(self.output.products.count, 1)
        }
    }
    
    func test_reloadTrigger_failed_showError() {
        // arrange
        useCase.getProductsReturnValue = .failure(TestError())
        
        // act
        reloadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.useCase.getProductsCalled)
            XCTAssert(self.output.alert.isShowing)
        }
    }
    
    func test_selectTrigger_showProductDetail() {
        // act
        loadTrigger.send(())
        selectTrigger.send(IndexPath(row: 0, section: 0))
        
        // assert
        wait {
            XCTAssert(self.navigator.showProductDetailCalled)
        }
    }
}
