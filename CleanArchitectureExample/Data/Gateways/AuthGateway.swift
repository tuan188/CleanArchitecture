//
//  AuthGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import Foundation
import Factory

protocol AuthGatewayProtocol {
    func login(username: String, password: String) -> AnyPublisher<Void, Error>
}

struct AuthGateway: AuthGatewayProtocol {
    func login(username: String, password: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                promise(.success(()))
            })
        }
        .eraseToAnyPublisher()
    }
}

struct PreviewAuthGateway: AuthGatewayProtocol {
    func login(username: String, password: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

extension Container {
    var authGateway: Factory<AuthGatewayProtocol> {
        Factory(self) {
            AuthGateway()
        }
        .onPreview {
            PreviewAuthGateway()
        }
    }
}
