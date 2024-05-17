//
//  ErrorTracker.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

// typealias for ErrorTracker, a PassthroughSubject used to track errors
public typealias ErrorTracker = PassthroughSubject<Error, Never>

extension Publisher where Failure: Error {
    
    /// Track errors emitted by the publisher using an ErrorTracker.
    /// 
    ///  - Parameter errorTracker: An instance of ErrorTracker used to track errors emitted by the publisher.
    ///  - Returns: A publisher that emits the same output and failure types as the original publisher.
    public func trackError(_ errorTracker: ErrorTracker) -> AnyPublisher<Output, Failure> {
        return handleEvents(
            // When completion is received, if it's a failure, send the error to the errorTracker
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    errorTracker.send(error)
                }
            }
        )
        // Erase the type of the publisher to AnyPublisher to hide implementation details
        .eraseToAnyPublisher()
    }
}

