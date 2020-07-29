//
//  ShowingProductList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import SwiftUI

protocol ShowingProductList {
    var assembler: Assembler { get }
    var navigationController: UINavigationController { get }
}

extension ShowingProductList {
    func showProductList() {
        let view: ProductsView = assembler.resolve(navigationController: navigationController)
        let vc = UIHostingController(rootView: view)
        vc.title = "Product List"
        navigationController.pushViewController(vc, animated: true)
    }
}
