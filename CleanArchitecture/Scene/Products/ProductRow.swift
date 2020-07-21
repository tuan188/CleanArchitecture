//
//  ProductRow.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import SwiftUI

struct ProductRow: View {
    let viewModel: ProductItemViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.name)
                .bold()
            Spacer()
            Text(viewModel.price)
                .foregroundColor(.green)
        }
    }
}

struct ProductRow_Previews: PreviewProvider {
    static var previews: some View {
        let product = Product(id: 1, name: "iPhone", price: 999)
        return ProductRow(viewModel: ProductItemViewModel(product: product))
    }
}
