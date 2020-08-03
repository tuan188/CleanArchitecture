//
//  ViewModelType+GetItem.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/31/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public struct GetItemResult<T> {
    public var item: AnyPublisher<T, Never>
    public var error: AnyPublisher<Error, Never>
    public var isLoading: AnyPublisher<Bool, Never>
    public var isReloading: AnyPublisher<Bool, Never>
    
    // swiftlint:disable:next line_length large_tuple
    public var destructured: (AnyPublisher<T, Never>, AnyPublisher<Error, Never>, AnyPublisher<Bool, Never>, AnyPublisher<Bool, Never>) {
        return (item, error, isLoading, isReloading)
    }
    
    public init(item: AnyPublisher<T, Never>,
                error: AnyPublisher<Error, Never>,
                isLoading: AnyPublisher<Bool, Never>,
                isReloading: AnyPublisher<Bool, Never>) {
        self.item = item
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
    }
}

extension ViewModel {
    public func getItem<Item, Input>(
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Input, Never>,
        getItem: @escaping (Input) -> AnyPublisher<Item, Error>,
        reloadTrigger: AnyPublisher<Input, Never>,
        reloadItem: @escaping (Input) -> AnyPublisher<Item, Error>)
        -> GetItemResult<Item> {
            
        let loadingActivityTracker = ActivityTracker(false)
        let reloadingActivityTracker = ActivityTracker(false)
        
        let item = Publishers.Merge(
                loadTrigger.map { ScreenLoadingType.loading($0) },
                reloadTrigger.map { ScreenLoadingType.reloading($0) }
            )
            .filter { _ in
                !loadingActivityTracker.value && !reloadingActivityTracker.value
            }
            .map { triggerType -> AnyPublisher<Item, Never> in
                switch triggerType {
                case .loading(let input):
                    return getItem(input)
                        .trackError(errorTracker)
                        .trackActivity(loadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                case .reloading(let input):
                    return reloadItem(input)
                        .trackError(errorTracker)
                        .trackActivity(reloadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
            
        let error = errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityTracker.eraseToAnyPublisher()
        let isReloading = reloadingActivityTracker.eraseToAnyPublisher()
        
        return GetItemResult(
            item: item,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading
        )
    }
    
    public func getItem<Item, Input>(
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        getItem: @escaping (Input) -> AnyPublisher<Item, Error>)
        -> GetItemResult<Item> {
            
        return self.getItem(
            errorTracker: errorTracker,
            loadTrigger: loadTrigger,
            getItem: getItem,
            reloadTrigger: reloadTrigger,
            reloadItem: getItem
        )
    }
    
    public func getItem<Item, Input>(
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        getItem: @escaping (Input) -> AnyPublisher<Item, Error>)
        -> GetItemResult<Item> {
            
        return self.getItem(
            errorTracker: ErrorTracker(),
            loadTrigger: loadTrigger,
            getItem: getItem,
            reloadTrigger: reloadTrigger,
            reloadItem: getItem
        )
    }
}
