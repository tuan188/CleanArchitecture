//
//  ViewModel+GetList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public struct GetListInput<TriggerInput, Item, MappedItem> {
    let errorTracker: ErrorTracker
    let loadTrigger: AnyPublisher<TriggerInput, Never>
    let reloadTrigger: AnyPublisher<TriggerInput, Never>
    let getItems: (TriggerInput) -> AnyPublisher<[Item], Error>
    let reloadItems: (TriggerInput) -> AnyPublisher<[Item], Error>
    let mapper: (Item) -> MappedItem
    
    public init(errorTracker: ErrorTracker,
                loadTrigger: AnyPublisher<TriggerInput, Never>,
                getItems: @escaping (TriggerInput) -> AnyPublisher<[Item], Error>,
                reloadTrigger: AnyPublisher<TriggerInput, Never>,
                reloadItems: @escaping (TriggerInput) -> AnyPublisher<[Item], Error>,
                mapper: @escaping (Item) -> MappedItem) {
        self.errorTracker = errorTracker
        self.loadTrigger = loadTrigger
        self.reloadTrigger = reloadTrigger
        self.getItems = getItems
        self.reloadItems = reloadItems
        self.mapper = mapper
    }
}

public extension GetListInput {
    init(errorTracker: ErrorTracker = ErrorTracker(),
         loadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         getItems: @escaping (TriggerInput) -> AnyPublisher<[Item], Error>,
         mapper: @escaping (Item) -> MappedItem) {
        self.init(errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItems: getItems,
                  reloadTrigger: reloadTrigger,
                  reloadItems: getItems,
                  mapper: mapper)
    }
}

public extension GetListInput where Item == MappedItem {
    init(errorTracker: ErrorTracker = ErrorTracker(),
         loadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         getItems: @escaping (TriggerInput) -> AnyPublisher<[Item], Error>) {
        self.init(errorTracker: errorTracker,
                  loadTrigger: loadTrigger,
                  getItems: getItems,
                  reloadTrigger: reloadTrigger,
                  reloadItems: getItems,
                  mapper: { $0 })
    }
}

public struct GetListResult<Item> {
    public var items: AnyPublisher<[Item], Never>
    public var error: AnyPublisher<Error, Never>
    public var isLoading: AnyPublisher<Bool, Never>
    public var isReloading: AnyPublisher<Bool, Never>
    
    // swiftlint:disable:next large_tuple
    public var destructured: (
        AnyPublisher<[Item], Never>,
        AnyPublisher<Error, Never>,
        AnyPublisher<Bool, Never>,
        AnyPublisher<Bool, Never>) {
        return (items, error, isLoading, isReloading)
    }
    
    public init(items: AnyPublisher<[Item], Never>,
                error: AnyPublisher<Error, Never>,
                isLoading: AnyPublisher<Bool, Never>,
                isReloading: AnyPublisher<Bool, Never>) {
        self.items = items
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
    }
}

extension ViewModel {
    public func getList<TriggerInput, Item, MappedItem>(input: GetListInput<TriggerInput, Item, MappedItem>)
        -> GetListResult<MappedItem> {
            
        let loadingActivityTracker = ActivityTracker(false)
        let reloadingActivityTracker = ActivityTracker(false)
        
        let items = Publishers.Merge(
                input.loadTrigger.map { ScreenLoadingType.loading($0) },
                input.reloadTrigger.map { ScreenLoadingType.reloading($0) }
            )
            .filter { _ in
                !loadingActivityTracker.value && !reloadingActivityTracker.value
            }
            .map { triggerType -> AnyPublisher<[Item], Never> in
                switch triggerType {
                case .loading(let triggerInput):
                    return input.getItems(triggerInput)
                        .trackError(input.errorTracker)
                        .trackActivity(loadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                case .reloading(let triggerInput):
                    return input.reloadItems(triggerInput)
                        .trackError(input.errorTracker)
                        .trackActivity(reloadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .map { $0.map(input.mapper) }
            .eraseToAnyPublisher()
        
        let error = input.errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityTracker.eraseToAnyPublisher()
        let isReloading = reloadingActivityTracker.eraseToAnyPublisher()
        
        return GetListResult(
            items: items,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading
        )
    }
}
