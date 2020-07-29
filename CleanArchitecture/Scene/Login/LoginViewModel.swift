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
extension LoginViewModel: ViewModelType {
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
        @Published var alertMessage = ""
        @Published var alertTitle = ""
        @Published var showingAlert = false
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
                output.alertTitle = "Login successful"
                output.alertMessage = "Hello \(input.username). Welcome to the app!"
                output.showingAlert = true
            })
            .store(in: cancelBag)
        
        errorTracker
            .receive(on: RunLoop.main)
            .map { $0.localizedDescription }
            .handleEvents(receiveOutput: { errorMessage in
                output.alertTitle = "Error"
                output.showingAlert = !errorMessage.isEmpty
            })
            .assign(to: \.alertMessage, on: output)
            .store(in: cancelBag)
            
        activityTracker
            .receive(on: RunLoop.main)
            .assign(to: \.isLoading, on: output)
            .store(in: cancelBag)
        
        return output
    }
}
