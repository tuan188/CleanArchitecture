//
//  ValidationError.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 17/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

import Foundation

struct ValidationError: LocalizedError {
    let message: String
    
    var errorDescription: String? {
        return message
    }
}
