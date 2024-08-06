import Combine

/// A container that holds a collection of cancellable subscriptions.
/// Useful for managing the lifecycle of multiple Combine subscriptions.
open class CancelBag {
    /// The set of cancellable subscriptions.
    public fileprivate(set) var subscriptions = Set<AnyCancellable>()
    
    /// Cancels all the subscriptions stored in the `CancelBag`.
    public func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll(keepingCapacity: false)
    }
}

extension AnyCancellable {
    /// Stores the cancellable subscription in the specified `CancelBag`.
    ///
    /// - Parameter cancelBag: The `CancelBag` in which to store the subscription.
    public func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}

