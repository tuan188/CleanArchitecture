//
//  BaseViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/4/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Combine
import MBProgressHUD

class BaseViewController: UIViewController {  // swiftlint:disable:this final_class
    
//    var loadingSubscriber: GenericSubscriber<Bool> {
//        GenericSubscriber(self) { (vc, isLoading) in
//            if isLoading {
//                let hud = MBProgressHUD.showAdded(to: vc.view, animated: true)
//                hud.offset.y = -30
//            } else {
//                MBProgressHUD.hide(for: vc.view, animated: true)
//            }
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
