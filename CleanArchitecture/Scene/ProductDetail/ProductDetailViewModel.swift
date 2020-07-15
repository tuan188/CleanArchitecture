//
//  ProductDetailViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

struct ProductDetailViewModel {
    let navigator: ProductDetailNavigatorType
    let useCase: ProductDetailUseCaseType
    let product: Product
}

// MARK: - ViewModelType
extension ProductDetailViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    struct Output {
        let name: Driver<String>
        let price: Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
        let product = input.loadTrigger
            .map { self.product }
        
        let name = product
            .map { $0.name }
            .eraseToAnyPublisher()
        
        let price = product
            .map { $0.price.currency }
            .eraseToAnyPublisher()
        
        return Output(
            name: name,
            price: price
        )
    }
}
