//
//  ProductDetailNavigator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol ProductDetailNavigatorType {

}

struct ProductDetailNavigator: ProductDetailNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
}
