//
//  ProductsView.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import SwiftUI
import Combine
import SwiftUIRefresh

struct ProductsView: View {
    @ObservedObject var output: ProductsViewModel.Output
    
    private let cancelBag = CancelBag()
    private let loadTrigger = PassthroughSubject<Void, Never>()
    private let reloadTrigger = PassthroughSubject<Void, Never>()
    private let selectTrigger = PassthroughSubject<IndexPath, Never>()

    var body: some View {
        let products = output.products.enumerated().map { $0 }
        
        return LoadingView(isShowing: $output.isLoading, text: .constant("")) {
            VStack {
                List(products, id: \.element.name) { index, product in
                    Button(action: {
                       self.selectTrigger.send(IndexPath(row: index, section: 0))
                    }) {
                        ProductRow(viewModel: product)
                    }
                }
                .pullToRefresh(isShowing: self.$output.isReloading) {
                    self.reloadTrigger.send(())
                }
            }
            .navigationBarTitle("Product List")
            .navigationBarItems(trailing: Button("Refresh") {
                self.loadTrigger.send(())
            })
        }
        .alert(isPresented: $output.alert.isShowing) {
            Alert(
                title: Text(output.alert.title),
                message: Text(output.alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    init(viewModel: ProductsViewModel) {
        let input = ProductsViewModel.Input(
            loadTrigger: loadTrigger.eraseToAnyPublisher(),
            reloadTrigger: reloadTrigger.eraseToAnyPublisher(),
            selectTrigger: selectTrigger.eraseToAnyPublisher()
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
