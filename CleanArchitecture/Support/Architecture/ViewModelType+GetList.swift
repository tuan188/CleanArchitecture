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

extension ViewModelType {
    public func getList<Item, Input, MappedItem>(
        loadTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input) -> AnyPublisher<[Item], Error>,
        reloadTrigger: AnyPublisher<Input, Never>,
        reloadItems: @escaping (Input) -> AnyPublisher<[Item], Error>,
        mapper: @escaping (Item) -> MappedItem) -> GetListResult<MappedItem> {
        
        let errorTracker = ErrorTracker()
        let loadingActivityTracker = ActivityTracker()
        let reloadingActivityTracker = ActivityTracker()
        
        let error = errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityTracker.eraseToAnyPublisher()
        let isReloading = reloadingActivityTracker.eraseToAnyPublisher()
        
        let isLoadingOrReloading = isLoading.merge(with: isReloading)
            .prepend(false)
        
        let items = Publishers.Merge(
                loadTrigger.map { ScreenLoadingType.loading($0) },
                reloadTrigger.map { ScreenLoadingType.reloading($0) }
            )
            .withLatestFrom(isLoadingOrReloading) {
                (triggerType: $0, loading: $1)
            }
            .filter { !$0.loading }
            .map { $0.triggerType }
            .map { triggerType -> Driver<[Item]> in
                switch triggerType {
                case .loading(let input):
                    return getItems(input)
                        .trackError(errorTracker)
                        .trackActivity(loadingActivityTracker)
                        .asDriver()
                case .reloading(let input):
                    return reloadItems(input)
                        .trackError(errorTracker)
                        .trackActivity(reloadingActivityTracker)
                        .asDriver()
                }
            }
            .switchToLatest()
            .map { $0.map(mapper) }
            .eraseToAnyPublisher()
        
        return GetListResult(
            items: items,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading
        )
    }
}
