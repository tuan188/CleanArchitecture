//
//  LoginViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import SwiftUI
import CombineExt
import Factory

class LoginViewModel: LogIn { // swiftlint:disable:this final_class
    @Injected(\.authGateway)
    var authGateway: AuthGatewayProtocol
    
    init(authGateway: AuthGatewayProtocol) {
        self.authGateway = authGateway
    }
}

// MARK: - ViewModelType
extension LoginViewModel: ObservableObject, ViewModel {
    final class Input: ObservableObject {
        @Published var username = ""
        @Published var password = ""
        let loginTrigger: AnyPublisher<Void, Never>
        
        init(loginTrigger: AnyPublisher<Void, Never>) {
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
        let activityTracker = ActivityIndicator(false)
        let output = Output()
        
        let usernameValidation = Publishers
            .CombineLatest(input.$username, input.loginTrigger)
            .map { $0.0 }
            .map(validateUserName(_:))
        
        usernameValidation
            .asDriver()
            .map { $0.message ?? "" }
            .assign(to: \.usernameValidationMessage, on: output)
            .store(in: cancelBag)
        
        let passwordValidation = Publishers
            .CombineLatest(input.$password, input.loginTrigger)
            .map { $0.0 }
            .map(validatePassword(_:))
            
        passwordValidation
            .asDriver()
            .map { $0.message ?? "" }
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
            .map { [unowned self] _ in
                self.login(username: input.username, password: input.password)
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
