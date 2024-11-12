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
import Factory
import CleanArchitecture

struct ProductsView: View {
    final class Triggers: ObservableObject {
        var load = PassthroughSubject<Void, Never>()
        var reload = PassthroughSubject<Void, Never>()
        var select = PassthroughSubject<IndexPath, Never>()
    }
    
    @StateObject var viewModel: ProductsViewModel
    @StateObject var output: ProductsViewModel.Output
    @StateObject var cancelBag: CancelBag
    @StateObject var triggers: Triggers

    var body: some View {
        let products = output.products.enumerated().map { $0 }
        
        return LoadingView(isShowing: $output.isLoading, text: .constant("")) {
            VStack {
                List(products, id: \.element.name) { index, product in
                    Button(action: {
                        self.triggers.select.send(IndexPath(row: index, section: 0))
                    }) {
                        ProductRow(viewModel: product)
                    }
                }
                .pullToRefresh(isShowing: self.$output.isReloading) {
                    self.triggers.reload.send(())
                }
            }
            .navigationBarTitle("Product List")
            .navigationBarItems(trailing: Button("Refresh") {
                self.triggers.load.send(())
            })
        }
        .alert(isPresented: $output.alert.isShowing) {
            Alert(
                title: Text(output.alert.title),
                message: Text(output.alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onLoad {
            triggers.load.send(())
        }
    }
    
    init(viewModel: ProductsViewModel) {
        let triggers = Triggers()
        let cancelBag = CancelBag()
        
        let input = ProductsViewModel.Input(
            loadTrigger: triggers.load.eraseToAnyPublisher(),
            reloadTrigger: triggers.reload.eraseToAnyPublisher(),
            selectTrigger: triggers.select.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._output = StateObject(wrappedValue: output)
        self._cancelBag = StateObject(wrappedValue: cancelBag)
        self._triggers = StateObject(wrappedValue: triggers)
    }
}

struct ProductsView_Preview: PreviewProvider {
    static var previews: some View {
        ProductsView(viewModel: ProductsViewModel(navigationController: UINavigationController()))
    }
}

extension Container {
    func productsView(navigationController: UINavigationController) -> Factory<ProductsView> {
        Factory(self) {
            ProductsView(viewModel: ProductsViewModel(navigationController: navigationController))
        }
    }
}
