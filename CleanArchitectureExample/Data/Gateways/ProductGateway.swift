//
//  ProductGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import Foundation
import Factory

protocol ProductGatewayProtocol {
    func getProducts() -> AnyPublisher<[Product], Error>
}

struct ProductGateway: ProductGatewayProtocol {
    func getProducts() -> AnyPublisher<[Product], Error> {
        Future<[Product], Error> { promise in
            let products = [
                Product(id: 0, name: "iPhone", price: 999),
                Product(id: 1, name: "MacBook", price: 2999)
            ]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                promise(.success(products))
            }
        }
        .eraseToAnyPublisher()
    }
}

struct PreviewProductGateway: ProductGatewayProtocol {
    func getProducts() -> AnyPublisher<[Product], Error> {
        Future<[Product], Error> { promise in
            let products = [
                Product(id: 0, name: "iPhone", price: 999),
                Product(id: 1, name: "MacBook", price: 2999)
            ]
            
            promise(.success(products))
        }
        .eraseToAnyPublisher()
    }
}

extension Container {
    var productGateway: Factory<ProductGatewayProtocol> {
        Factory(self) { ProductGateway() }
            .onPreview {
                PreviewProductGateway()
            }
    }
}
