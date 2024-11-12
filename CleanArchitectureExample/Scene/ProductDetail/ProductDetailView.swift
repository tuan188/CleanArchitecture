//
//  ProductDetailView.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import SwiftUI
import Combine
import Factory

struct ProductDetailView: View {
    final class Triggers: ObservableObject {
        var load = PassthroughSubject<Void, Never>()
    }
    
    @StateObject var viewModel: ProductDetailViewModel
    @StateObject var output: ProductDetailViewModel.Output
    @StateObject var cancelBag: CancelBag
    @StateObject var triggers: Triggers
    
    var body: some View {
        VStack {
            HStack {
                Text("Product name:")
                Text(output.name)
                Spacer()
            }
            .padding([.leading, .top])
            HStack {
                Text("Price:")
                Text(output.price)
                Spacer()
            }
            .padding([.leading, .top])
            Spacer()
        }
        .onLoad {
            triggers.load.send(())
        }
    }
    
    init(viewModel: ProductDetailViewModel) {
        let cancelBag = CancelBag()
        let triggers = Triggers()
        let input = ProductDetailViewModel.Input(loadTrigger: triggers.load.eraseToAnyPublisher())
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._output = StateObject(wrappedValue: output)
        self._cancelBag = StateObject(wrappedValue: cancelBag)
        self._triggers = StateObject(wrappedValue: triggers)
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let product = Product(id: 1, name: "iPhone", price: 999)
        return Container.shared.productDetailView(product: product)()
    }
}

extension Container {
    func productDetailView(product: Product) -> Factory<ProductDetailView> {
        Factory(self) {
            let vm = ProductDetailViewModel(product: product)
            return ProductDetailView(viewModel: vm)
        }
    }
}
