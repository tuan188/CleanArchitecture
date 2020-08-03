//
//  ViewModelType+GetList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public struct GetListResult<T> {
    public var items: AnyPublisher<[T], Never>
    public var error: AnyPublisher<Error, Never>
    public var isLoading: AnyPublisher<Bool, Never>
    public var isReloading: AnyPublisher<Bool, Never>
    
    // swiftlint:disable:next large_tuple
    public var destructured: (
        AnyPublisher<[T], Never>,
        AnyPublisher<Error, Never>,
        AnyPublisher<Bool, Never>,
        AnyPublisher<Bool, Never>) {
        return (items, error, isLoading, isReloading)
    }
    
    public init(items: AnyPublisher<[T], Never>,
                error: AnyPublisher<Error, Never>,
                isLoading: AnyPublisher<Bool, Never>,
                isReloading: AnyPublisher<Bool, Never>) {
        self.items = items
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
    }
}

enum ScreenLoadingType<Input> {
    case loading(Input)
    case reloading(Input)
}

extension ViewModel {
    public func getList<Item, Input, MappedItem>(
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input) -> AnyPublisher<[Item], Error>,
        reloadTrigger: AnyPublisher<Input, Never>,
        reloadItems: @escaping (Input) -> AnyPublisher<[Item], Error>,
        mapper: @escaping (Item) -> MappedItem)
        -> GetListResult<MappedItem> {
        
        let loadingActivityTracker = ActivityTracker(false)
        let reloadingActivityTracker = ActivityTracker(false)
        
        let items = Publishers.Merge(
                loadTrigger.map { ScreenLoadingType.loading($0) },
                reloadTrigger.map { ScreenLoadingType.reloading($0) }
            )
            .filter { _ in
                !loadingActivityTracker.value && !reloadingActivityTracker.value
            }
            .map { triggerType -> AnyPublisher<[Item], Never> in
                switch triggerType {
                case .loading(let input):
                    return getItems(input)
                        .trackError(errorTracker)
                        .trackActivity(loadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                case .reloading(let input):
                    return reloadItems(input)
                        .trackError(errorTracker)
                        .trackActivity(reloadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .map { $0.map(mapper) }
            .eraseToAnyPublisher()
        
        let error = errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityTracker.eraseToAnyPublisher()
        let isReloading = reloadingActivityTracker.eraseToAnyPublisher()
        
        return GetListResult(
            items: items,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading
        )
    }
    
    public func getList<Item, Input, MappedItem>(
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input) -> AnyPublisher<[Item], Error>,
        mapper: @escaping (Item) -> MappedItem)
        -> GetListResult<MappedItem> {

        getList(
            errorTracker: errorTracker,
            loadTrigger: loadTrigger,
            getItems: getItems,
            reloadTrigger: reloadTrigger,
            reloadItems: getItems,
            mapper: mapper
        )
    }
    
    public func getList<Item, Input, MappedItem>(
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input) -> AnyPublisher<[Item], Error>,
        mapper: @escaping (Item) -> MappedItem)
        -> GetListResult<MappedItem> {
            
        return getList(
            errorTracker: ErrorTracker(),
            loadTrigger: loadTrigger,
            getItems: getItems,
            reloadTrigger: reloadTrigger,
            reloadItems: getItems,
            mapper: mapper
        )
    }
    
    public func getList<Item, Input>(
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input) -> AnyPublisher<[Item], Error>)
        -> GetListResult<Item> {
            
            return getList(
                errorTracker: errorTracker,
                loadTrigger: loadTrigger,
                getItems: getItems,
                reloadTrigger: reloadTrigger,
                reloadItems: getItems,
                mapper: { $0 }
            )
    }
    
    public func getList<Item, Input>(
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input) -> AnyPublisher<[Item], Error>)
        -> GetListResult<Item> {
            
            return getList(
                errorTracker: ErrorTracker(),
                loadTrigger: loadTrigger,
                getItems: getItems,
                reloadTrigger: reloadTrigger,
                reloadItems: getItems,
                mapper: { $0 }
            )
    }
}
