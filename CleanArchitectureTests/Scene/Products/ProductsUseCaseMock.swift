//
//  ProductsUseCaseMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/11/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import Combine

final class ProductsUseCaseMock: ProductsUseCaseType {
    
    // MARK: - getProducts
    
    var getProductsCalled = false
    var getProductsReturnValue = Result<[Product], Error>.success([Product()])
    
    func getProducts() -> Observable<[Product]> {
        getProductsCalled = true
        return getProductsReturnValue.publisher.eraseToAnyPublisher()
    }
}
