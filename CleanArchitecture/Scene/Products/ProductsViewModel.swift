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
extension ProductsViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let reloadTrigger: Driver<Void>
        let selectTrigger: Driver<IndexPath>
    }
    
    final class Output: ObservableObject {
        @Published var products = [ProductItemViewModel]()
        @Published var isLoading = false
        @Published var isReloading = false
        @Published var alertMessage = ""
        @Published var alertTitle = ""
        @Published var showingAlert = false
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let result = getList(
            loadTrigger: input.loadTrigger,
            reloadTrigger: input.reloadTrigger,
            getItems: useCase.getProducts
        )
        
        let (products, error, isLoading, isReloading) = result.destructured
        
        let output = Output()
        
        products
            .map { $0.map(ProductItemViewModel.init) }
            .assign(to: \.products, on: output)
            .store(in: cancelBag)
        
        error
            .receive(on: RunLoop.main)
            .map { $0.localizedDescription }
            .handleEvents(receiveOutput: { errorMessage in
                output.alertTitle = "Error"
                output.showingAlert = !errorMessage.isEmpty
            })
            .assign(to: \.alertMessage, on: output)
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
