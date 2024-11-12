//
//  ShowProductDetail.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import SwiftUI
import Factory

protocol ShowProductDetail {
    var navigationController: UINavigationController { get }
}

extension ShowProductDetail {
    func showProductDetail(product: Product) {
        let view = Container.shared.productDetailView(product: product)()
        let vc = UIHostingController(rootView: view)
        vc.title = "Product Detail"
        navigationController.pushViewController(vc, animated: true)
    }
}
