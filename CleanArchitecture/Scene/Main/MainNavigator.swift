//
//  MainNavigator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

protocol MainNavigatorType {
    
}

struct MainNavigator: MainNavigatorType {
    unowned let assembler: Assembler
    unowned let window: UIWindow
}
