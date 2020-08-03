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
extension ProductDetailViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
    }
    
    final class Output: ObservableObject {
        @Published var name = ""
        @Published var price = ""
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let product = input.loadTrigger
            .map { self.product }
        
        let output = Output()
        
        product
            .map { $0.name }
            .assign(to: \.name, on: output)
            .store(in: cancelBag)
        
        product
            .map { $0.price.currency }
            .assign(to: \.price, on: output)
            .store(in: cancelBag)
        
        return output
    }
}
