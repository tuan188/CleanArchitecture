//
//  ShowingLogin.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import SwiftUI

protocol ShowingLogin {
    var assembler: Assembler { get }
    var navigationController: UINavigationController { get }
}

extension ShowingLogin {
    func showLogin() {
        let view: LoginView = assembler.resolve(navigationController: navigationController)
        let vc = UIHostingController(rootView: view)
        vc.title = "Login"
        navigationController.pushViewController(vc, animated: true)
    }
}
