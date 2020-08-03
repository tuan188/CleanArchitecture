//
//  LoginViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine
import SwiftUI

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
        @Published var isLoginEnabled = false
        @Published var isLoading = false
        @Published var alert = AlertMessage()
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let errorTracker = ErrorTracker()
        let activityTracker = ActivityTracker(false)
        let output = Output()
        
        input.loginTrigger
            .map {
                self.useCase.login(username: input.username, password: input.password)
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
