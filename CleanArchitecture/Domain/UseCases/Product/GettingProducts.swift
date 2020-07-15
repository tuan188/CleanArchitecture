//
//  GettingProducts.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

protocol GettingProducts {
    var productGateway: ProductGatewayType { get }
}

extension GettingProducts {
    func getProducts(page: Int) -> AnyPublisher<PagingInfo<Product>, Error> {
        return productGateway.getProducts(page: page)
    }
}
