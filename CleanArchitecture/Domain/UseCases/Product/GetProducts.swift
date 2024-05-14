//
//  GetProducts.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

protocol GetProducts {
    var productGateway: ProductGatewayProtocol { get }
}

extension GetProducts {
    func getProducts() -> Observable<[Product]> {
        productGateway.getProducts()
    }
}
