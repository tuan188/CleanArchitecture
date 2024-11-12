//
//  ProductsViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import UIKit
import Factory
import CleanArchitecture

class ProductsViewModel: GetProducts, ShowProductDetail { // swiftlint:disable:this final_class
    unowned let navigationController: UINavigationController
    
    @Injected(\.productGateway)
    var productGateway: ProductGatewayProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func vm_showProductDetail(product: Product) {
        showProductDetail(product: product)
    }
    
    func vm_getProducts() -> AnyPublisher<[Product], Error> {
        getProducts()
    }
    
    deinit {
        print("ProductsViewModel deinit")
    }
}

// MARK: - ViewModel
extension ProductsViewModel: ObservableObject, ViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
        let reloadTrigger: AnyPublisher<Void, Never>
        let selectTrigger: AnyPublisher<IndexPath, Never>
    }
    
    final class Output: ObservableObject {
        @Published var products = [ProductItemViewModel]()
        @Published var isLoading = false
        @Published var isReloading = false
        @Published var alert = AlertMessage()
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let config = ListFetchConfig(initialLoadTrigger: input.loadTrigger,
                                     reloadTrigger: input.reloadTrigger,
                                     fetchItems: self.vm_getProducts)
        
        let (products, error, isLoading, isReloading) = fetchList(config: config).destructured
        
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
                self.vm_showProductDetail(product: product)
            })
            .store(in: cancelBag)
        
        return output
    }
}
