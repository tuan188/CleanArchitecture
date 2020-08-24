//
//  LoggingIn.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import Foundation

struct LoginDto {
    var username = ""
    var password = ""
}

protocol LoggingIn {
    var authGateway: AuthGatewayType { get }
}

extension LoggingIn {
    func login(dto: LoginDto) -> Observable<Void> {
        authGateway.login(dto: dto)
    }
}
