//
//  ShowProductList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import SwiftUI
import Factory

protocol ShowProductList {
    var navigationController: UINavigationController { get }
}

extension ShowProductList {
    func showProductList() {
        let view = Container.shared.productsView(navigationController: navigationController)()
        let vc = UIHostingController(rootView: view)
        vc.title = "Product List"
        navigationController.pushViewController(vc, animated: true)
    }
}
