//
//  GatewaysAssembler.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol GatewaysAssembler {
    func resolve() -> ProductGatewayProtocol
    func resolve() -> AuthGatewayProtocol
    func resolve() -> RepoGatewayProtocol
}

extension GatewaysAssembler where Self: DefaultAssembler {
    func resolve() -> ProductGatewayProtocol {
        ProductGateway()
    }

    func resolve() -> AuthGatewayProtocol {
        AuthGateway()
    }

    func resolve() -> RepoGatewayProtocol {
        RepoGateway()
    }
}

extension GatewaysAssembler where Self: PreviewAssembler {
    func resolve() -> ProductGatewayProtocol {
        PreviewProductGateway()
    }
    
    func resolve() -> AuthGatewayProtocol {
        AuthGateway()
    }
    
    func resolve() -> RepoGatewayProtocol {
        RepoGateway()
    }
}
