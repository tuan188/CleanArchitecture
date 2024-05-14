//
//  MockProductGateway.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 14/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import Foundation

final class FakeProductGateway: ProductGatewayProtocol {
    func getProducts() -> CleanArchitecture.Observable<[CleanArchitecture.Product]> {
        fatalError()
    }
}
