//
//  ShowLogin.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import SwiftUI
import Factory

protocol ShowLogin {
    var navigationController: UINavigationController { get }
}

extension ShowLogin {
    func showLogin() {
        let view = Container.shared.loginView(navigationController: navigationController)()
        let vc = UIHostingController(rootView: view)
        vc.title = "Login"
        navigationController.pushViewController(vc, animated: true)
    }
}
