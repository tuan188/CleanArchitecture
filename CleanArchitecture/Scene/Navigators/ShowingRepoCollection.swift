//
//  ShowingRepoCollection.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/5/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol ShowingRepoCollection {
    var assembler: Assembler { get }
    var navigationController: UINavigationController { get }
}

extension ShowingRepoCollection {
    func showRepoCollection() {
        let vc: RepoCollectionViewController = assembler.resolve(navigationController: navigationController)
        navigationController.pushViewController(vc, animated: true)
    }
}
