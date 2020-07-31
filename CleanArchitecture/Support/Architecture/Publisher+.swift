//
//  Publisher+.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/15/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

extension Publisher {
    public func sink() -> AnyCancellable {
        return self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
