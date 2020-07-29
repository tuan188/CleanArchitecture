//
//  GatewaysAssembler.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol GatewaysAssembler {
    func resolve() -> ProductGatewayType
    func resolve() -> AuthGatewayType
}

extension GatewaysAssembler where Self: DefaultAssembler {
    func resolve() -> ProductGatewayType {
        ProductGateway()
    }

    func resolve() -> AuthGatewayType {
        AuthGateway()
    }
}

extension GatewaysAssembler where Self: PreviewAssembler {
    func resolve() -> ProductGatewayType {
        PreviewProductGateway()
    }
    
    func resolve() -> AuthGatewayType {
        AuthGateway()
    }
}
