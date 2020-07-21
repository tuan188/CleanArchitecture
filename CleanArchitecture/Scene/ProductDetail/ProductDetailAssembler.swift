//
//  ProductDetailAssembler.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol ProductDetailAssembler {
    func resolve(navigationController: UINavigationController, product: Product) -> ProductDetailView
    func resolve(navigationController: UINavigationController, product: Product) -> ProductDetailViewModel
    func resolve(navigationController: UINavigationController) -> ProductDetailNavigatorType
    func resolve() -> ProductDetailUseCaseType
}

extension ProductDetailAssembler {
    func resolve(navigationController: UINavigationController, product: Product) -> ProductDetailView {
        ProductDetailView(viewModel: resolve(navigationController: navigationController, product: product))
    }
    
    func resolve(navigationController: UINavigationController, product: Product) -> ProductDetailViewModel {
        ProductDetailViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve(),
            product: product
        )
    }
}

extension ProductDetailAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> ProductDetailNavigatorType {
        ProductDetailNavigator(assembler: self, navigationController: navigationController)
    }
    
    func resolve() -> ProductDetailUseCaseType {
        ProductDetailUseCase()
    }
}

extension ProductDetailAssembler where Self: PreviewAssembler {
    func resolve(navigationController: UINavigationController) -> ProductDetailNavigatorType {
        ProductDetailNavigator(assembler: self, navigationController: navigationController)
    }
    
    func resolve() -> ProductDetailUseCaseType {
        ProductDetailUseCase()
    }
}
