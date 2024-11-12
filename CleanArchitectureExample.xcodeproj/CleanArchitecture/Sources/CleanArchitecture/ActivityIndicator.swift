import Combine

// typealias for ActivityIndicator, a CurrentValueSubject that tracks activity status (true/false)
public typealias ActivityIndicator = CurrentValueSubject<Bool, Never>

extension Publisher where Failure: Error {
    /// Track activity status of the publisher using an ActivityIndicator.
    ///
    /// - Parameter activityIndicator: An instance of ActivityIndicator used to track activity status of the publisher.
    /// - Returns: A publisher that emits the same output and failure types as the original publisher.
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> AnyPublisher<Output, Failure> {
        return handleEvents(
            receiveSubscription: { _ in
                activityIndicator.send(true) // Send true to indicate activity started
            },
            receiveCompletion: { _ in
                activityIndicator.send(false) // Send false to indicate activity ended
            },
            receiveCancel: {
                activityIndicator.send(false) // Send false to indicate activity ended due to cancellation
            }
        )
        .eraseToAnyPublisher() // Erase the type of the publisher to AnyPublisher to hide implementation details
    }
}
