//
//  ProductItemViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

struct ProductItemViewModel {
    let product: Product
    let name: String
    let price: String
    
    init(product: Product) {
        self.product = product
        self.name = product.name
        self.price = product.price.currency
    }
}
