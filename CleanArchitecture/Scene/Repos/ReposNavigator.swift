//
//  ReposNavigator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol ReposNavigatorType {
    func toRepoDetail(repo: Repo)
}

struct ReposNavigator: ReposNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController
    
    func toRepoDetail(repo: Repo) {
        
    }
}
