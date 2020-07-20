//
//  ViewModelType+GetList.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public struct GetListResult<T> {
    public var items: Observable<[T]>
    public var error: Observable<Error>
    public var isLoading: Observable<Bool>
    public var isReloading: Observable<Bool>
    
    // swiftlint:disable:next large_tuple
    public var destructured: (Observable<[T]>, Observable<Error>, Observable<Bool>, Observable<Bool>) {
        return (items, error, isLoading, isReloading)
    }
    
    public init(items: Observable<[T]>,
                error: Observable<Error>,
                isLoading: Observable<Bool>,
                isReloading: Observable<Bool>) {
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
        loadTrigger: Observable<Input>,
        getItems: @escaping (Input) -> Observable<[Item]>,
        reloadTrigger: Observable<Input>,
        reloadItems: @escaping (Input) -> Observable<[Item]>,
        mapper: @escaping (Item) -> MappedItem) -> GetListResult<MappedItem> {
        
        let errorTracker = ErrorTracker()
        let loadingActivityIndicator = ActivityIndicator()
        let reloadingActivityIndicator = ActivityIndicator()
        
        let error = errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityIndicator.eraseToAnyPublisher()
        let isReloading = reloadingActivityIndicator.eraseToAnyPublisher()
        
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
            .map { triggerType -> Observable<[Item]> in
                switch triggerType {
                case .loading(let input):
                    return getItems(input)
                        .trackError(errorTracker)
                        .trackActivity(loadingActivityIndicator)
                case .reloading(let input):
                    return reloadItems(input)
                        .trackError(errorTracker)
                        .trackActivity(reloadingActivityIndicator)
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
