//
//  UIViewController+Combine.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Combine
import MBProgressHUD

extension UIViewController {
    var alertSubscriber: GenericSubscriber<AlertMessage> {
        GenericSubscriber(self) { (vc, alertMessage) in
            vc.showAlert(alertMessage)
        }
    }
    
    var loadingSubscriber: GenericSubscriber<Bool> {
        GenericSubscriber(self) { (vc, isLoading) in
            if isLoading {
                let hud = MBProgressHUD.showAdded(to: vc.view, animated: true)
                hud.offset.y = -30
            } else {
                MBProgressHUD.hide(for: vc.view, animated: true)
            }
        }
    }
}
