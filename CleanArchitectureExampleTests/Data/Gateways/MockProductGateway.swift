//
//  MockProductGateway.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 14/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import Foundation
import Combine

final class FakeProductGateway: ProductGatewayProtocol {
    // swiftlint:disable:next unavailable_function
    func getProducts() -> AnyPublisher<[CleanArchitecture.Product], Error> {
        fatalError("N/A")
    }
}
