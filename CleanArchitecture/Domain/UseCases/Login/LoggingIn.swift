//
//  LoggingIn.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import Foundation

protocol LoggingIn {
    var authGateway: AuthGatewayType { get }
}

extension LoggingIn {
    func login(username: String, password: String) -> Observable<Void> {
        authGateway.login(username: username, password: password)
    }
}
