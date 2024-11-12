//
//  Double+.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/15/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

extension Double {
    var currency: String {
        return String(format: "$%.02f", self)
    }
}
