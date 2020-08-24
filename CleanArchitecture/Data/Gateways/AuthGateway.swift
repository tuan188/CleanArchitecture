//
//  AuthGateway.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import Foundation

protocol AuthGatewayType {
    func login(dto: LoginDto) -> Observable<Void>
}

struct AuthGateway: AuthGatewayType {
    func login(dto: LoginDto) -> Observable<Void> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                if dto.username.isEmpty || dto.password.isEmpty {
                    promise(.failure(AppError.error(message: "Invalid username/password!")))
                } else {
                    promise(.success(()))
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
