//
//  ProductsNavigatorMock.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/11/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture

final class ProductsNavigatorMock: ProductsNavigatorType {
    // MARK: - showProductDetail
    
    var showProductDetailCalled = false
    
    func showProductDetail(product: Product) {
        showProductDetailCalled = true
    }
}
