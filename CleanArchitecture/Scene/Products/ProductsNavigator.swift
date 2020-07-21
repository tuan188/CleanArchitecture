//
//  ProductsNavigator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import SwiftUI

protocol ProductsNavigatorType {
    func showProductDetail(product: Product)
}

struct ProductsNavigator: ProductsNavigatorType, ShowingProductDetail {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
}
