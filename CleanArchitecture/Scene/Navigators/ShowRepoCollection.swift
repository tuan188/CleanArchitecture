//
//  ShowRepoCollection.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/5/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Factory

protocol ShowRepoCollection {
    var navigationController: UINavigationController { get }
}

extension ShowRepoCollection {
    func showRepoCollection() {
        let vc = Container.shared.repoCollectionViewController(navigationController: navigationController)()
        navigationController.pushViewController(vc, animated: true)
    }
}
