//
//  Observable.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 17/5/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    public func asObservable() -> AnyPublisher<Output, Error> {
        self.mapError { $0 }
            .eraseToAnyPublisher()
    }
}
