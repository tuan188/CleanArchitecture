//
//  MockProductGateway.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 14/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

@testable import CleanArchitectureExample
import Foundation
import Combine
import CleanArchitecture

final class FakeProductGateway: ProductGatewayProtocol {
    // swiftlint:disable:next unavailable_function
    func getProducts() -> AnyPublisher<[CleanArchitectureExample.Product], Error> {
        fatalError("N/A")
    }
}
