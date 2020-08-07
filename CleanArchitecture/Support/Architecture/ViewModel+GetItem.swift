//
//  ViewModel+GetItem.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/31/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public struct GetItemInput<TriggerInput, Item> {
    let errorTracker: ErrorTracker
    let loadTrigger: AnyPublisher<TriggerInput, Never>
    let reloadTrigger: AnyPublisher<TriggerInput, Never>
    let getItem: (TriggerInput) -> AnyPublisher<Item, Error>
    let reloadItem: (TriggerInput) -> AnyPublisher<Item, Error>
    
    public init(errorTracker: ErrorTracker,
                loadTrigger: AnyPublisher<TriggerInput, Never>,
                getItem: @escaping (TriggerInput) -> AnyPublisher<Item, Error>,
                reloadTrigger: AnyPublisher<TriggerInput, Never>,
                reloadItem: @escaping (TriggerInput) -> AnyPublisher<Item, Error>) {
        self.errorTracker = errorTracker
        self.loadTrigger = loadTrigger
        self.reloadTrigger = reloadTrigger
        self.getItem = getItem
        self.reloadItem = reloadItem
    }
}

public extension GetItemInput {
    init(errorTracker: ErrorTracker = ErrorTracker(),
         loadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         getItem: @escaping (TriggerInput) -> AnyPublisher<Item, Error>) {
        self.init(errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItem: getItem,
                  reloadTrigger: reloadTrigger,
                  reloadItem: getItem)
    }
}

public struct GetItemResult<Item> {
    public var item: AnyPublisher<Item, Never>
    public var error: AnyPublisher<Error, Never>
    public var isLoading: AnyPublisher<Bool, Never>
    public var isReloading: AnyPublisher<Bool, Never>
    
    // swiftlint:disable:next large_tuple
    public var destructured: (
        AnyPublisher<Item, Never>,
        AnyPublisher<Error, Never>,
        AnyPublisher<Bool, Never>,
        AnyPublisher<Bool, Never>) {
        return (item, error, isLoading, isReloading)
    }
    
    public init(item: AnyPublisher<Item, Never>,
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
    public func getItem<TriggerInput, Item>(input: GetItemInput<TriggerInput, Item>) -> GetItemResult<Item> {
        let loadingActivityTracker = ActivityTracker(false)
        let reloadingActivityTracker = ActivityTracker(false)
        
        let item = Publishers.Merge(
                input.loadTrigger.map { ScreenLoadingType.loading($0) },
                input.reloadTrigger.map { ScreenLoadingType.reloading($0) }
            )
            .filter { _ in
                !loadingActivityTracker.value && !reloadingActivityTracker.value
            }
            .map { triggerType -> AnyPublisher<Item, Never> in
                switch triggerType {
                case .loading(let triggerInput):
                    return input.getItem(triggerInput)
                        .trackError(input.errorTracker)
                        .trackActivity(loadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                case .reloading(let triggerInput):
                    return input.reloadItem(triggerInput)
                        .trackError(input.errorTracker)
                        .trackActivity(reloadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
            
        let error = input.errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityTracker.eraseToAnyPublisher()
        let isReloading = reloadingActivityTracker.eraseToAnyPublisher()
        
        return GetItemResult(
            item: item,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading
        )
    }
}
