//
//  ProductDetailView.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import SwiftUI
import Combine

struct ProductDetailView: View {
    @ObservedObject var output: ProductDetailViewModel.Output
    
    private let viewModel: ProductDetailViewModel
    private let cancelBag = CancelBag()
    private let loadTrigger = PassthroughSubject<Void, Never>()
    
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
    }
    
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        let input = ProductDetailViewModel.Input(loadTrigger: loadTrigger.asDriver())
        self.output = viewModel.transform(input, cancelBag: cancelBag)
        loadTrigger.send(())
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let product = Product(id: 1, name: "iPhone", price: 999)
        return ProductDetailView(
            viewModel: PreviewAssembler().resolve(navigationController: UINavigationController(), product: product)
        )
    }
}
