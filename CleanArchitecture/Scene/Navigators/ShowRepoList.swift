//
//  ShowRepoList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Factory

protocol ShowRepoList {
    var navigationController: UINavigationController { get }
}

extension ShowRepoList {
    func showRepoList() {
        let vc = Container.shared.reposViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
