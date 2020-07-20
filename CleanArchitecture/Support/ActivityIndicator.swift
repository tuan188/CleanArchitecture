//
//  ActivityIndicator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public typealias ActivityIndicator = PassthroughSubject<Bool, Error>

extension Publisher where Failure: Error {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveSubscription: { _ in
            activityIndicator.send(true)
        }, receiveCompletion: { _ in
            activityIndicator.send(false)
        })
        .eraseToAnyPublisher()
    }
}
