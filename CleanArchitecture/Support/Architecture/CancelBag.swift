//
//  CancelBag.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/21/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

/// A container that holds a collection of cancellable subscriptions.
open class CancelBag {
    /// The set of cancellable subscriptions.
    public var subscriptions = Set<AnyCancellable>()
    
    /// Cancels all the subscriptions stored in the `CancelBag`.
    public func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
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

