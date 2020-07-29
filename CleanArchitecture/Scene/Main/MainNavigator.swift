//
//  MainNavigator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol MainNavigatorType {
    func toProducts()
    func toSectionedProducts()
    func toRepos()
    func toRepoCollection()
    func toUsers()
    func toLogin()
}

struct MainNavigator: MainNavigatorType, ShowingProductList {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
    
    func toProducts() {
        showProductList()
    }
    
    func toSectionedProducts() {
//        let vc: SectionedProductsViewController = assembler.resolve(navigationController: navigationController)
//        navigationController.pushViewController(vc, animated: true)
    }
    
    func toRepos() {
//        let vc: ReposViewController = assembler.resolve(navigationController: navigationController)
//        navigationController.pushViewController(vc, animated: true)
    }
    
    func toRepoCollection() {
//        let vc: RepoCollectionViewController = assembler.resolve(navigationController: navigationController)
//        navigationController.pushViewController(vc, animated: true)
    }
    
    func toUsers() {
//        let vc: UserListViewController = assembler.resolve(navigationController: navigationController)
//        navigationController.pushViewController(vc, animated: true)
    }
    
    func toLogin() {
//        let vc: LoginViewController = assembler.resolve(navigationController: navigationController)
//        navigationController.pushViewController(vc, animated: true)
    }
}
