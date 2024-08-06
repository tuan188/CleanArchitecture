import Combine
import Foundation

extension Publisher {
    /// Converts the publisher into a driver, ensuring events are received on the main thread and ignoring errors.
    ///
    /// - Returns: A publisher that never emits errors and receives events on the main thread.
    public func asDriver() -> AnyPublisher<Output, Never> {
        self.catch { _ in Empty() } // Ignore errors
            .receive(on: RunLoop.main) // Receive events on the main thread
            .share(replay: 1) // Share the subscription among multiple subscribers with replay
            .eraseToAnyPublisher() // Erase to AnyPublisher
    }
    
    /// Converts the publisher into a driver, ensuring events are received on the main thread and replacing errors with a default value.
    ///
    /// - Parameter defaultValue: The default value to emit in case of errors.
    /// - Returns: A publisher that never emits errors and receives events on the main thread.
    public func asDriver(defaultValue: Output) -> AnyPublisher<Output, Never> {
        self.replaceError(with: defaultValue) // Replace errors with a default value
            .receive(on: RunLoop.main) // Receive events on the main thread
            .share(replay: 1) // Share the subscription among multiple subscribers with replay
            .eraseToAnyPublisher() // Erase to AnyPublisher
    }
}

