//
//  Observable.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public typealias Observable<T> = AnyPublisher<T, Error>

extension Publisher {
    public func Observable() -> Observable<Output> {
        return self.genericError()
    }
    
    public static func just(_ output: Output) -> Observable<Output> {
        return Just(output).genericError()
    }
    
    public static func empty() -> Observable<Output> {
        return Empty().eraseToAnyPublisher()
    }
}
