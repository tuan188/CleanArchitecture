//
//  ProductGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import Foundation

protocol ProductGatewayType {
    func getProducts() -> Observable<[Product]>
}

struct ProductGateway: ProductGatewayType {
    func getProducts() -> Observable<[Product]> {
        Future<[Product], Error> { promise in
            let products = [
                Product(id: 0, name: "iPhone", price: 999),
                Product(id: 1, name: "MacBook", price: 2999)
            ]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                promise(.failure(AppError.error(message: "Get product list failed!")))
                promise(.success(products))
            }
        }
        .eraseToAnyPublisher()
    }
}

struct PreviewProductGateway: ProductGatewayType {
    func getProducts() -> Observable<[Product]> {
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
