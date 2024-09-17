//
//  LoginUITests.swift
//  CleanArchitectureUITests
//
//  Created by Tuan Truong on 17/9/24.
//  Copyright © 2024 Tuan Truong. All rights reserved.
//

import XCTest
import UIKit

final class LoginUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app.terminate()
    }
    
    private func showLogin() {
        let app = XCUIApplication()
        app.launch()
        
        let tableView = app.tables.element(boundBy: 0)
        _ = tableView.waitForExistence(timeout: 2)
        
        let cell = tableView.cells.element(boundBy: 3)
        XCTAssertTrue(cell.exists, "The cell in section 3 should exist")
        cell.tap()
        
        let navigationBar = app.navigationBars.element(boundBy: 0)
        _  = navigationBar.waitForExistence(timeout: 2)
        XCTAssertTrue(navigationBar.exists, "The navigation bar should exist")
        
        let expectedTitle = "Login"
        XCTAssertEqual(navigationBar.staticTexts.element.label, expectedTitle, "The screen title is incorrect")
    }
    
    @MainActor
    func testLoginSuccess() {
        showLogin()
        
        let userTextField = app.textFields["userTextField"]
        let passwordTextField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]

        // Input valid user
        userTextField.tap()
        userTextField.typeText("user")

        // Input valid password
        passwordTextField.tap()
        passwordTextField.typeText("validpassword")

        // Tap login button
        loginButton.tap()

        // Login success
        let alert = app.alerts["Login successful"]
        let exists = alert.waitForExistence(timeout: 2)
        XCTAssertTrue(exists, "The alert should appear on the screen")
    }
}
