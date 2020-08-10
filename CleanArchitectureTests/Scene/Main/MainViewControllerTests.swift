//
//  MainViewControllerTests.swift
//  CleanArchitectureTests
//
//  Created by Tuan Truong on 8/10/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import Reusable

final class MainViewControllerTests: XCTestCase {
    var viewController: MainViewController!
    
    override func setUp() {
        super.setUp()
        viewController = MainViewController.instantiate()
    }
    
    func test_ibOutlets() {
        _ = viewController.view
        XCTAssertNotNil(viewController.tableView)
    }
}
