//
//  Publisher+.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/15/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

extension Publisher {
    func genericError() -> AnyPublisher<Self.Output, Error> {
        return self
            .mapError({ (error: Self.Failure) -> Error in
                return error
            })
            .eraseToAnyPublisher()
    }
}
