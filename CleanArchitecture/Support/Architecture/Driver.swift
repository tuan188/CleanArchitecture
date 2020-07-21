//
//  Driver.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/15/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public typealias Driver<T> = AnyPublisher<T, Never>

extension Publisher {
    func asDriver() -> Driver<Output> {
        return self.catch { _ in Empty() }
            .eraseToAnyPublisher()
    }
}
