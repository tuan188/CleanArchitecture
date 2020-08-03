//
//  AppViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

struct AppViewModel {
    let navigator: AppNavigatorType
    let useCase: AppUseCaseType
}

// MARK: - ViewModelType
extension AppViewModel: ViewModel {
    struct Input {
        let startTrigger: Driver<Void>
    }
    
    final class Output: ObservableObject {
        
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        input.startTrigger
            .handleEvents(receiveOutput: navigator.toMain)
            .sink()
            .store(in: cancelBag)
        
        return Output()
    }
}
