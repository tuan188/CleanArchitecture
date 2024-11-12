//
//  UIViewController+Debug.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

extension UIViewController {
    public func logDeinit() {
        print(String(describing: type(of: self)) + " deinit")
    }
}
