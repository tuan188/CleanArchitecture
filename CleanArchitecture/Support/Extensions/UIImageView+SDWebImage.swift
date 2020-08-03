//
//  UIImageView+SDWebImage.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    func setImage(with url: URL?, completion: (() -> Void)? = nil) {
        self.sd_setImage(with: url, placeholderImage: nil, options: .refreshCached) { (_, _, _, _) in
            completion?()
        }
    }
}
