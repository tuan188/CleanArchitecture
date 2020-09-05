//
//  GetPageDto.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/1/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Dto

struct GetPageDto: Dto {
    var page = 1
    var perPage = 10
    var usingCache = false

    var validatedProperties: [ValidatedProperty] {
        return []
    }
}
