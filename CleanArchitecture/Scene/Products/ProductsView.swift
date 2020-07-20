//
//  ProductsView.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import SwiftUI
import Combine

struct ProductsView: View {
    
    let viewModel: ProductsViewModel
    
    private let loadTrigger = PassthroughSubject<Void, Error>()
    private let reloadTrigger = PassthroughSubject<Void, Error>()
    
    @State var products: [Product] = []
    
    private var subscriptions = Set<AnyCancellable>()

    var body: some View {
        List(products) { product in
            Text(product.name)
        }
    }
    
    init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
        
        bindViewModel()
        loadTrigger.send(())
    }
    
    mutating func bindViewModel() {
        let input = ProductsViewModel.Input(
            loadTrigger: loadTrigger.eraseToAnyPublisher(),
            reloadTrigger: reloadTrigger.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input)
    }
}

struct ProductsView_Preview: PreviewProvider {
    static var previews: some View {
        let viewModel: ProductsViewModel = DefaultAssembler().resolve(
            navigationController: UINavigationController()
        )
        
        return ProductsView(viewModel: viewModel)
    }
}
