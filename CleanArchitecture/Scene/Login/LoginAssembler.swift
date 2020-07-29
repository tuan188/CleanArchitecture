//
//  LoginAssembler.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol LoginAssembler {
    func resolve(navigationController: UINavigationController) -> LoginView
    func resolve(navigationController: UINavigationController) -> LoginViewModel
    func resolve(navigationController: UINavigationController) -> LoginNavigatorType
    func resolve() -> LoginUseCaseType
}

extension LoginAssembler {
    func resolve(navigationController: UINavigationController) -> LoginView {
        LoginView(viewModel: resolve(navigationController: navigationController))
    }
    
    func resolve(navigationController: UINavigationController) -> LoginViewModel {
        LoginViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve()
        )
    }
}

extension LoginAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> LoginNavigatorType {
        LoginNavigator(assembler: self, navigationController: navigationController)
    }
    
    func resolve() -> LoginUseCaseType {
        LoginUseCase(authGateway: resolve())
    }
}

extension LoginAssembler where Self: PreviewAssembler {
    func resolve(navigationController: UINavigationController) -> LoginNavigatorType {
        LoginNavigator(assembler: self, navigationController: navigationController)
    }
    
    func resolve() -> LoginUseCaseType {
        LoginUseCase(authGateway: resolve())
    }
}
