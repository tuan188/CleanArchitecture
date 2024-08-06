import Foundation
import Combine

extension Publisher {
    public func asObservable() -> AnyPublisher<Output, Error> {
        self.mapError { $0 }
            .eraseToAnyPublisher()
    }
}
