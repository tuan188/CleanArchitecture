//
//  ActivityTracker.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

// typealias for ActivityTracker, a CurrentValueSubject that tracks activity status (true/false)
public typealias ActivityTracker = CurrentValueSubject<Bool, Never>

extension Publisher where Failure: Error {
    /// Track activity status of the publisher using an ActivityTracker.
    ///
    /// - Parameter activityTracker: An instance of ActivityTracker used to track activity status of the publisher.
    /// - Returns: A publisher that emits the same output and failure types as the original publisher.
    public func trackActivity(_ activityTracker: ActivityTracker) -> AnyPublisher<Output, Failure> {
        return handleEvents(
            // When subscription is received, send true to activityTracker indicating activity is in progress
            receiveSubscription: { _ in
                activityTracker.send(true)
            },
            // When completion (success or failure) is received, send false to activityTracker indicating activity has ended
            receiveCompletion: { _ in
                activityTracker.send(false)
            }
        )
        // Erase the type of the publisher to AnyPublisher to hide implementation details
        .eraseToAnyPublisher()
    }
}

