//
//  AppError.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/20/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Foundation

enum AppError: LocalizedError {
    case none
    case error(message: String)

    var errorDescription: String? {
        switch self {
        case let .error(message):
            return message
        default:
            return ""
        }
    }
}
