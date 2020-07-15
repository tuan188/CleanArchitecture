//
//  ProductsViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

struct ProductsViewModel {
    let navigator: ProductsNavigatorType
    let useCase: ProductsUseCaseType
}

// MARK: - ViewModelType
extension ProductsViewModel: ViewModelType {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Error>
    }
    
    struct Output {
        let products: AnyPublisher<[Product], Error>
    }
    
    func transform(_ input: Input) -> Output {
        let products = input.loadTrigger
            .map {
                self.useCase
                    .getProducts(page: 1)
                    .map { $0.items }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
        
        return Output(products: products)
    }
}
