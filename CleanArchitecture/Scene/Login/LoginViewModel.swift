//
//  LoginViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import SwiftUI
import ValidatedPropertyKit
import CombineExt

struct LoginViewModel {
    let navigator: LoginNavigatorType
    let useCase: LoginUseCaseType
}

// MARK: - ViewModelType
extension LoginViewModel: ViewModel {
    final class Input: ObservableObject {
        @Published var username = ""
        @Published var password = ""
        let loginTrigger: Driver<Void>
        
        init(loginTrigger: Driver<Void>) {
            self.loginTrigger = loginTrigger
        }
    }
    
    final class Output: ObservableObject {
        @Published var isLoginEnabled = true
        @Published var isLoading = false
        @Published var alert = AlertMessage()
        @Published var usernameValidationMessage = ""
        @Published var passwordValidationMessage = ""
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let errorTracker = ErrorTracker()
        let activityTracker = ActivityTracker(false)
        let output = Output()
        
        let usernameValidation = Publishers
            .CombineLatest(input.$username, input.loginTrigger)
            .map { $0.0 }
            .map(LoginDto.validateUserName(_:))
        
        usernameValidation
            .asDriver()
            .map { $0.message }
            .assign(to: \.usernameValidationMessage, on: output)
            .store(in: cancelBag)
        
        let passwordValidation = Publishers
            .CombineLatest(input.$password, input.loginTrigger)
            .map { $0.0 }
            .map(LoginDto.validatePassword(_:))
            
        passwordValidation
            .asDriver()
            .map { $0.message }
            .assign(to: \.passwordValidationMessage, on: output)
            .store(in: cancelBag)
        
        Publishers
            .CombineLatest(usernameValidation, passwordValidation)
            .map { $0.0.isValid && $0.1.isValid }
            .assign(to: \.isLoginEnabled, on: output)
            .store(in: cancelBag)
        
        input.loginTrigger
            .delay(for: 0.1, scheduler: RunLoop.main)  // waiting for username/password validation
            .filter { output.isLoginEnabled }
            .map { _ in
                self.useCase.login(dto: LoginDto(username: input.username, password: input.password))
                    .trackError(errorTracker)
                    .trackActivity(activityTracker)
                    .asDriver()
            }
            .switchToLatest()
            .sink(receiveValue: {
                let message = AlertMessage(title: "Login successful",
                                           message: "Hello \(input.username). Welcome to the app!",
                                           isShowing: true)
                output.alert = message
            })
            .store(in: cancelBag)
        
        errorTracker
            .receive(on: RunLoop.main)
            .map { AlertMessage(error: $0) }
            .assign(to: \.alert, on: output)
            .store(in: cancelBag)
            
        activityTracker
            .receive(on: RunLoop.main)
            .assign(to: \.isLoading, on: output)
            .store(in: cancelBag)
        
        return output
    }
}
