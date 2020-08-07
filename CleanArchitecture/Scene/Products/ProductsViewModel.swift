//
//  ProductsViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import UIKit

struct ProductsViewModel {
    let navigator: ProductsNavigatorType
    let useCase: ProductsUseCaseType
}

// MARK: - ViewModelType
extension ProductsViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
        let selectTrigger: Driver<IndexPath>
    }
    
    final class Output: ObservableObject {
        @Published var products = [ProductItemViewModel]()
        @Published var isLoading = false
        @Published var isReloading = false
        @Published var alert = AlertMessage()
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let getListInput = GetListInput(loadTrigger: input.loadTrigger,
                                        reloadTrigger: input.reloadTrigger,
                                        getItems: useCase.getProducts)

        let (products, error, isLoading, isReloading) = getList(input: getListInput).destructured
        
        let output = Output()
        
        products
            .map { $0.map(ProductItemViewModel.init) }
            .assign(to: \.products, on: output)
            .store(in: cancelBag)
        
        error
            .receive(on: RunLoop.main)
            .map { AlertMessage(error: $0) }
            .assign(to: \.alert, on: output)
            .store(in: cancelBag)
        
        isLoading
            .assign(to: \.isLoading, on: output)
            .store(in: cancelBag)
        
        isReloading
            .assign(to: \.isReloading, on: output)
            .store(in: cancelBag)
        
        input.selectTrigger
            .sink(receiveValue: { indexPath in
                let product = output.products[indexPath.row].product
                self.navigator.showProductDetail(product: product)
            })
            .store(in: cancelBag)
        
        return output
    }
}
