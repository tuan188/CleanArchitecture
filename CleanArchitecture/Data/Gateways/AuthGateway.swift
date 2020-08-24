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
