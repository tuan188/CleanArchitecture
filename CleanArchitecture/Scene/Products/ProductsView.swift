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
    
    @ObservedObject var output: ProductsViewModel.Output
    
    private let cancelBag = CancelBag()
    private let viewModel: ProductsViewModel
    private let loadTrigger = PassthroughSubject<Void, Never>()
    private let reloadTrigger = PassthroughSubject<Void, Never>()

    var body: some View {
        NavigationView {
            VStack {
                List(output.products) { product in
                    Text(product.name)
                }
            }
            .navigationBarTitle("Products")
            .navigationBarItems(trailing: Button("Reload") {
                self.loadTrigger.send(())
            })
        }
//        .onAppear {
//            self.loadTrigger.send(())
//        }
    }
    
    init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
        
        let input = ProductsViewModel.Input(
            loadTrigger: loadTrigger.eraseToAnyPublisher(),
            reloadTrigger: reloadTrigger.eraseToAnyPublisher()
        )
        
        self.output = viewModel.transform(input, cancelBag: cancelBag)
        self.loadTrigger.send(())
    }
}

struct ProductsView_Preview: PreviewProvider {
    static var previews: some View {
        let viewModel: ProductsViewModel = PreviewAssembler().resolve(
            navigationController: UINavigationController()
        )
        
        return ProductsView(viewModel: viewModel)
    }
}
