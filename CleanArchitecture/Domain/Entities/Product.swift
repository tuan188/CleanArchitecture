//
//  Product.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

struct Product: Identifiable {
    var id = 0
    var name = ""
    var price = 0.0
}

// MARK: - Fake
extension Array where Element == Product {
    static var fake: Self {
        [
            Product()
        ]
    }
}
