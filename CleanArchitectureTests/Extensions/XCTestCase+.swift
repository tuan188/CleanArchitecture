//
//  XCTestCase+.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import XCTest
import Combine

extension XCTestCase {
    func wait(interval: TimeInterval = 0.1, completion: @escaping (() -> Void)) {
        let exp = expectation(description: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            completion()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: interval + 0.1) // add 0.1 for sure asyn after called
    }
}

extension XCTestCase {
    typealias CompetionResult = (expectation: XCTestExpectation, cancellable: AnyCancellable)
    
    func expectCompletion<T: Publisher>(of publisher: T,
                                        timeout: TimeInterval = 2,
                                        file: StaticString = #file,
                                        line: UInt = #line) -> CompetionResult {
        let exp = expectation(description: "Successful completion of " + String(describing: publisher))
        
        let cancellable = publisher
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    exp.fulfill()
                }
            }, receiveValue: { _ in })
            
        return (exp, cancellable)
    }
}
