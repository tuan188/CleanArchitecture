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
    func login(dto: LoginDto) -> AnyPublisher<Void, Error>
}

struct AuthGateway: AuthGatewayProtocol {
    func login(dto: LoginDto) -> AnyPublisher<Void, Error> {
        guard let username = dto.username,
            let password = dto.password else {
            return Empty().eraseToAnyPublisher()
        }
        
        print(username, password)
        
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                promise(.success(()))
            })
        }
        .eraseToAnyPublisher()
    }
}

struct PreviewAuthGateway: AuthGatewayProtocol {
    func login(dto: LoginDto) -> AnyPublisher<Void, Error> {
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
    }
    
    var previewAuthGateway: Factory<AuthGatewayProtocol> {
        Factory(self) {
            PreviewAuthGateway()
        }
    }
}
