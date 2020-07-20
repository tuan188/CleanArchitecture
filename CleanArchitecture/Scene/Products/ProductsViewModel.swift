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
        let loadTrigger: Observable<Void>
        let reloadTrigger: Observable<Void>
    }
    
    struct Output {
        let products: Observable<[Product]>
        let error: Observable<Error>
        let isLoading: Observable<Bool>
        let isReloading: Observable<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let result = getList(loadTrigger: input.loadTrigger,
                             getItems: { _ in
                                self.useCase.getProducts(page: 1)
                                    .map { $0.items }
                                    .eraseToAnyPublisher()
                            }, reloadTrigger: input.reloadTrigger, reloadItems: { _ in
                                self.useCase.getProducts(page: 1)
                                    .map { $0.items }
                                    .eraseToAnyPublisher()
                            }, mapper: { $0 })
        
        let (products, error, isLoading, isReloading) = result.destructured
        
        return Output(products: products,
                      error: error,
                      isLoading: isLoading,
                      isReloading: isReloading)
    }
}
