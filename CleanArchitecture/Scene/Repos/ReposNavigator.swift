//
//  ReposNavigator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol ReposNavigatorProtocol {
    func toRepoDetail(repo: Repo)
}

struct ReposNavigator: ReposNavigatorProtocol {
    unowned let navigationController: UINavigationController
    
    func toRepoDetail(repo: Repo) {
        
    }
}
