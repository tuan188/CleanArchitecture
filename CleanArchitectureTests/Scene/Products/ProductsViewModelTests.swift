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
    private var viewModel: TestProductsViewModel!
    
    private var input: ProductsViewModel.Input!
    private var output: ProductsViewModel.Output!
    private var loadTrigger = PassthroughSubject<Void, Never>()
    private var reloadTrigger = PassthroughSubject<Void, Never>()
    private var selectTrigger = PassthroughSubject<IndexPath, Never>()
    
    private var cancelBag: CancelBag!
    
    override func setUp() {
        super.setUp()
        viewModel = TestProductsViewModel(navigationController: UINavigationController(),
                                          productGateway: FakeProductGateway())
        
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
        viewModel.getProductsReturnValue = Fail(error: TestError()).eraseToAnyPublisher()
        
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
        viewModel.getProductsReturnValue = Fail(error: TestError()).eraseToAnyPublisher()
        
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
    
    var getProductsReturnValue = Just([Product].fake)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    
    var showProductDetailCalled = false
    
    override func vm_getProducts() -> Observable<[Product]> {
        getProductsCalled = true
        return getProductsReturnValue
    }
    
    override func vm_showProductDetail(product: Product) {
        showProductDetailCalled = true
    }
}
