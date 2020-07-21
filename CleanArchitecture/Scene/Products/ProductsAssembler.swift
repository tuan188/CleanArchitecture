//
//  ProductsAssembler.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol ProductsAssembler {
    func resolve(navigationController: UINavigationController) -> ProductsView
    func resolve(navigationController: UINavigationController) -> ProductsViewModel
    func resolve(navigationController: UINavigationController) -> ProductsNavigatorType
    func resolve() -> ProductsUseCaseType
}

extension ProductsAssembler {
    func resolve(navigationController: UINavigationController) -> ProductsView {
        return ProductsView(viewModel: resolve(navigationController: navigationController))
    }
    
    func resolve(navigationController: UINavigationController) -> ProductsViewModel {
        return ProductsViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve()
        )
    }
}

extension ProductsAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> ProductsNavigatorType {
        return ProductsNavigator(assembler: self, navigationController: navigationController)
    }
    
    func resolve() -> ProductsUseCaseType {
        return ProductsUseCase(productGateway: resolve())
    }
}

extension ProductsAssembler where Self: PreviewAssembler {
    func resolve(navigationController: UINavigationController) -> ProductsNavigatorType {
        return ProductsNavigator(assembler: self, navigationController: navigationController)
    }
    
    func resolve() -> ProductsUseCaseType {
        return ProductsUseCase(productGateway: resolve())
    }
}
