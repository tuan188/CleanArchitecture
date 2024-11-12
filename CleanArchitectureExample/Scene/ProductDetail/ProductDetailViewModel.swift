//
//  ProductDetailViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

final class ProductDetailViewModel {
    let product: Product
    
    init(product: Product) {
        self.product = product
    }
    
    deinit {
        print("ProductDetailViewModel deinit")
    }
}

// MARK: - ViewModel
extension ProductDetailViewModel: ViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
    }
    
    final class Output: ObservableObject {
        @Published var name = ""
        @Published var price = ""
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let product = input.loadTrigger
            .map {
                self.product
            }
        
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
