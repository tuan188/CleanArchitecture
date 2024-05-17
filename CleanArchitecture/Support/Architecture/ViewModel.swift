//
//  ViewModelType.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public protocol ViewModel {
    // Associated types Input and Output to define the input and output types for the ViewModel
    associatedtype Input
    associatedtype Output
    
    /// Transforms the input into output and manages subscriptions.
    ///
    /// - Parameters:
    ///   - input: The input for the transformation.
    ///   - cancelBag: The cancel bag to manage subscriptions and prevent retain cycles.
    /// - Returns: The transformed output.
    func transform(_ input: Input, cancelBag: CancelBag) -> Output
}
