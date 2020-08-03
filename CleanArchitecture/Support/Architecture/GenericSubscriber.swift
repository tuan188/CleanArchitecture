//
//  GenericSubscriber.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

struct GenericSubscriber<Value>: Subscriber {  // swiftlint:disable:this final_class
    var combineIdentifier = CombineIdentifier()
    private let _subscribing: (Value) -> Void
    
    init<Target: AnyObject>(_ target: Target, subscribing: @escaping (Target, Value) -> Void) {
        weak var weakTarget = target
        
        self._subscribing = { value in
            if let target = weakTarget {
                subscribing(target, value)
            }
        }
    }
    
    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        
    }
    
    func receive(_ input: Value) -> Subscribers.Demand {
        _subscribing(input)
        return .unlimited
    }
}
