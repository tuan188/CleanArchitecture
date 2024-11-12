//
//  ProductsViewModelTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/11/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitectureExample
import XCTest
import Combine
import CleanArchitecture

final class ProductsViewModelTests: XCTestCase {
    private var viewModel: TestProductsViewModel!
    
    private var input: ProductsViewModel.Input!
    private var output: ProductsViewModel.Output!
    private var loadTrigger = PassthroughSubject<Void, Never>()
    private var reloadTrigger = PassthroughSubject<Void, Never>()
    private var selectTrigger = PassthroughSubject<IndexPath, Never>()
    
    private var cancelBag: CancelBag!
    
    override func setUp() {
        super.setUp()
        viewModel = TestProductsViewModel(navigationController: UINavigationController())
        
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
            XCTAssert(self.viewModel.getProductsCalled)
            XCTAssertEqual(self.output.products.count, 1)
        }
    }
    
    func test_loadTrigger_failed_showError() {
        // arrange
        viewModel.getProductsReturnValue = .failure(TestError())
        
        // act
        loadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.viewModel.getProductsCalled)
            XCTAssert(self.output.alert.isShowing)
        }
    }
    
    func test_reloadTrigger_getProducts() {
        // act
        reloadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.viewModel.getProductsCalled)
            XCTAssertEqual(self.output.products.count, 1)
        }
    }
    
    func test_reloadTrigger_failed_showError() {
        // arrange
        viewModel.getProductsReturnValue = .failure(TestError())
        
        // act
        reloadTrigger.send(())
        
        // assert
        wait {
            XCTAssert(self.viewModel.getProductsCalled)
            XCTAssert(self.output.alert.isShowing)
        }
    }
    
    func test_selectTrigger_showProductDetail() {
        // act
        loadTrigger.send(())
        selectTrigger.send(IndexPath(row: 0, section: 0))
        
        // assert
        wait {
            XCTAssert(self.viewModel.showProductDetailCalled)
        }
    }
}

final class TestProductsViewModel: ProductsViewModel {
    var getProductsCalled = false
    var getProductsReturnValue: Result<[Product], Error> = .success([Product].fake)
    var showProductDetailCalled = false
    
    override func vm_getProducts() -> AnyPublisher<[Product], Error> {
        getProductsCalled = true
        return getProductsReturnValue.publisher.eraseToAnyPublisher()
    }
    
    override func vm_showProductDetail(product: Product) {
        showProductDetailCalled = true
    }
}
