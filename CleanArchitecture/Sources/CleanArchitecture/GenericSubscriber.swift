//
//  GenericSubscriber.swift
//  CleanArchitecture
//
import Combine

/// A generic subscriber that holds a weak reference to a target to prevent retain cycles.
/// It subscribes to a publisher and invokes a closure with the emitted value.
public struct GenericSubscriber<Value>: Subscriber {
    public var combineIdentifier = CombineIdentifier()
    private let onReceiveValue: (Value) -> Void
    
    /// Initializes a `GenericSubscriber` with a weak reference to the target.
    ///
    /// - Parameters:
    ///   - target: The target object to receive values.
    ///   - subscribing: A closure to be invoked with the target and received value.
    public init<Target: AnyObject>(_ target: Target, subscribing: @escaping (Target, Value) -> Void) {
        weak var weakTarget = target
        self.onReceiveValue = { value in
            guard let target = weakTarget else { return }
            subscribing(target, value)
        }
    }
    
    public func receive(subscription: Subscription) {
        subscription.request(.unlimited) // Requests unlimited values from the publisher
    }
    
    public func receive(_ input: Value) -> Subscribers.Demand {
        onReceiveValue(input)
        return .none
    }
    
    public func receive(completion: Subscribers.Completion<Never>) {
        // Optionally handle completion if needed
    }
}
