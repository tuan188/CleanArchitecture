//
//  ShowingProductDetail.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import SwiftUI

protocol ShowingProductDetail {
    var assembler: Assembler { get }
    var navigationController: UINavigationController { get }
}

extension ShowingProductDetail {
    func showProductDetail(product: Product) {
        let view: ProductDetailView = assembler.resolve(navigationController: navigationController, product: product)
        let vc = UIHostingController(rootView: view)
        vc.title = "Product Detail"
        navigationController.pushViewController(vc, animated: true)
    }
}
