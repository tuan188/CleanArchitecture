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

struct MainNavigator: MainNavigatorType, ShowingProductList, ShowingLogin, ShowingRepoList, ShowingRepoCollection {
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
        showRepoList()
    }
    
    func toRepoCollection() {
        showRepoCollection()
    }
    
    func toUsers() {
//        let vc: UserListViewController = assembler.resolve(navigationController: navigationController)
//        navigationController.pushViewController(vc, animated: true)
    }
    
    func toLogin() {
        showLogin()
    }
}
