//
//  ProductGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

protocol ProductGatewayType {
    func getProducts(page: Int) -> Observable<PagingInfo<Product>>
}

struct ProductGateway: ProductGatewayType {
    func getProducts(page: Int) -> Observable<PagingInfo<Product>> {
        Future<PagingInfo<Product>, Error> { promise in
            let products = [
                Product(id: 0, name: "iPhone", price: 999),
                Product(id: 1, name: "MacBook", price: 2999)
            ]
            
            let page = PagingInfo(page: 1, items: products)
            promise(.success(page))
        }
        .eraseToAnyPublisher()
    }
}
