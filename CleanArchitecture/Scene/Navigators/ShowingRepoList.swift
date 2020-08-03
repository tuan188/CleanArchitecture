//
//  ShowingRepoList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol ShowingRepoList {
    var assembler: Assembler { get }
    var navigationController: UINavigationController { get }
}

extension ShowingRepoList {
    func showRepoList() {
        let vc: ReposViewController = assembler.resolve(navigationController: navigationController)
        navigationController.pushViewController(vc, animated: true)
    }
}
