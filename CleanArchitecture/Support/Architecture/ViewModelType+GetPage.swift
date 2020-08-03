//
//  ViewModelType+GetPage.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/31/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public struct GetPageResult<T> {
    public var page: AnyPublisher<PagingInfo<T>, Never>
    public var error: AnyPublisher<Error, Never>
    public var isLoading: AnyPublisher<Bool, Never>
    public var isReloading: AnyPublisher<Bool, Never>
    public var isLoadingMore: AnyPublisher<Bool, Never>
    
    // swiftlint:disable:next large_tuple line_length
    public var destructured: (AnyPublisher<PagingInfo<T>, Never>, AnyPublisher<Error, Never>, AnyPublisher<Bool, Never>, AnyPublisher<Bool, Never>, AnyPublisher<Bool, Never>) {
        return (page, error, isLoading, isReloading, isLoadingMore)
    }
    
    public init(page: AnyPublisher<PagingInfo<T>, Never>,
                error: AnyPublisher<Error, Never>,
                isLoading: AnyPublisher<Bool, Never>,
                isReloading: AnyPublisher<Bool, Never>,
                isLoadingMore: AnyPublisher<Bool, Never>) {
        self.page = page
        self.error = error
        self.isLoading = isLoading
        self.isReloading = isReloading
        self.isLoadingMore = isLoadingMore
    }
}

extension ViewModel {
    // swiftlint:disable:next function_parameter_count
    public func getPage<Item, Input, MappedItem>(
        pageSubject: CurrentValueSubject<PagingInfo<MappedItem>, Never>,
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input) -> AnyPublisher<PagingInfo<Item>, Error>,
        reloadTrigger: AnyPublisher<Input, Never>,
        reloadItems: @escaping (Input) -> AnyPublisher<PagingInfo<Item>, Error>,
        loadMoreTrigger: AnyPublisher<Input, Never>,
        loadMoreItems: @escaping (Input, Int) -> AnyPublisher<PagingInfo<Item>, Error>,
        mapper: @escaping (Item) -> MappedItem)
        -> GetPageResult<MappedItem> {
            
        let loadingActivityTracker = ActivityTracker(false)
        let reloadingActivityTracker = ActivityTracker(false)
        let loadingMoreActivityTracker = ActivityTracker(false)
        let loadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
            
        let loadItems = Publishers.Merge(
                loadTrigger.map { ScreenLoadingType.loading($0) },
                reloadTrigger.map { ScreenLoadingType.reloading($0) }
            )
            .filter { _ in
                !loadingActivityTracker.value
                    && !reloadingActivityTracker.value
                    && !(loadingMoreActivityTracker.value || loadingMoreSubject.value)
            }
            .map { triggerType -> AnyPublisher<PagingInfo<Item>, Never> in
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
            .handleEvents(receiveOutput: { page in
                let newPage = PagingInfo<MappedItem>(
                    page: page.page,
                    items: page.items.map(mapper),
                    hasMorePages: page.hasMorePages,
                    totalItems: page.totalItems,
                    itemsPerPage: page.itemsPerPage,
                    totalPages: page.totalPages
                )
                
                pageSubject.send(newPage)
            })
            
        let loadMoreItems = loadMoreTrigger
            .filter { _ in
                !loadingActivityTracker.value
                    && !reloadingActivityTracker.value
                    && !(loadingMoreActivityTracker.value || loadingMoreSubject.value)
            }
            .handleEvents(receiveOutput: { _ in
                if pageSubject.value.items.isEmpty {
                    loadingMoreSubject.send(false)
                }
            })
            .filter { _ in !pageSubject.value.items.isEmpty }
            .map { input -> AnyPublisher<PagingInfo<Item>, Never> in
                let page = pageSubject.value.page
                
                return loadMoreItems(input, page + 1)
                    .trackError(errorTracker)
                    .trackActivity(loadingMoreActivityTracker)
                    .catch { _ in Empty() }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .filter { !$0.items.isEmpty || !$0.hasMorePages }
            .handleEvents(receiveOutput: { page in
                let currentPage = pageSubject.value
                let items = currentPage.items + page.items.map(mapper)
                
                let newPage = PagingInfo<MappedItem>(
                    page: page.page,
                    items: items,
                    hasMorePages: page.hasMorePages,
                    totalItems: page.totalItems,
                    itemsPerPage: page.itemsPerPage,
                    totalPages: page.totalPages
                )
                
                pageSubject.send(newPage)
            })
            
        let page = Publishers.Merge(loadItems, loadMoreItems)
            .map { _ in pageSubject.value }
            .eraseToAnyPublisher()
        
        let error = errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityTracker.eraseToAnyPublisher()
        let isReloading = reloadingActivityTracker.eraseToAnyPublisher()
        let isLoadingMore = loadingMoreActivityTracker.eraseToAnyPublisher()
        
        return GetPageResult(
            page: page,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading,
            isLoadingMore: isLoadingMore
        )
    }
    
    // swiftlint:disable:next function_parameter_count
    public func getPage<Item, Input, MappedItem>(
        pageSubject: CurrentValueSubject<PagingInfo<MappedItem>, Never>,
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        loadMoreTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input, Int) -> AnyPublisher<PagingInfo<Item>, Error>,
        mapper: @escaping (Item) -> MappedItem)
        -> GetPageResult<MappedItem> {
            
        return getPage(
            pageSubject: pageSubject,
            errorTracker: errorTracker,
            loadTrigger: loadTrigger,
            getItems: { input in
                getItems(input, 1)
            },
            reloadTrigger: reloadTrigger,
            reloadItems: { input in
                getItems(input, 1)
            },
            loadMoreTrigger: loadMoreTrigger,
            loadMoreItems: getItems,
            mapper: mapper
        )
    }
    
    public func getPage<Item, Input>(
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        loadMoreTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input, Int) -> AnyPublisher<PagingInfo<Item>, Error>)
        -> GetPageResult<Item> {
            
        let pageSubject = CurrentValueSubject<PagingInfo<Item>, Never>(PagingInfo<Item>())
        
        return getPage(
            pageSubject: pageSubject,
            errorTracker: errorTracker,
            loadTrigger: loadTrigger,
            getItems: { input in
                getItems(input, 1)
            },
            reloadTrigger: reloadTrigger,
            reloadItems: { input in
                getItems(input, 1)
            },
            loadMoreTrigger: loadMoreTrigger,
            loadMoreItems: getItems,
            mapper: { $0 }
        )
    }
    
    public func getPage<Item, Input>(
        loadTrigger: AnyPublisher<Input, Never>,
        reloadTrigger: AnyPublisher<Input, Never>,
        loadMoreTrigger: AnyPublisher<Input, Never>,
        getItems: @escaping (Input, Int) -> AnyPublisher<PagingInfo<Item>, Error>)
        -> GetPageResult<Item> {
            
        let pageSubject = CurrentValueSubject<PagingInfo<Item>, Never>(PagingInfo<Item>())
        
        return getPage(
            pageSubject: pageSubject,
            errorTracker: ErrorTracker(),
            loadTrigger: loadTrigger,
            getItems: { input in
                getItems(input, 1)
            },
            reloadTrigger: reloadTrigger,
            reloadItems: { input in
                getItems(input, 1)
            },
            loadMoreTrigger: loadMoreTrigger,
            loadMoreItems: getItems,
            mapper: { $0 }
        )
    }
    
    public func getPage<Item>(
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Void, Never>,
        reloadTrigger: AnyPublisher<Void, Never>,
        loadMoreTrigger: AnyPublisher<Void, Never>,
        getItems: @escaping (Int) -> AnyPublisher<PagingInfo<Item>, Error>)
        -> GetPageResult<Item> {
            
        let pageSubject = CurrentValueSubject<PagingInfo<Item>, Never>(PagingInfo<Item>())
        
        return getPage(
            pageSubject: pageSubject,
            errorTracker: errorTracker,
            loadTrigger: loadTrigger,
            getItems: { _ in
                getItems(1)
            },
            reloadTrigger: reloadTrigger,
            reloadItems: { _ in
                getItems(1)
            },
            loadMoreTrigger: loadMoreTrigger,
            loadMoreItems: { _, page in
                getItems(page)
            },
            mapper: { $0 }
        )
    }
    
    public func getPage<Item>(
        loadTrigger: AnyPublisher<Void, Never>,
        reloadTrigger: AnyPublisher<Void, Never>,
        loadMoreTrigger: AnyPublisher<Void, Never>,
        getItems: @escaping (Int) -> AnyPublisher<PagingInfo<Item>, Error>)
        -> GetPageResult<Item> {
            
        let pageSubject = CurrentValueSubject<PagingInfo<Item>, Never>(PagingInfo<Item>())
        
        return getPage(
            pageSubject: pageSubject,
            errorTracker: ErrorTracker(),
            loadTrigger: loadTrigger,
            getItems: { _ in
                getItems(1)
            },
            reloadTrigger: reloadTrigger,
            reloadItems: { _ in
                getItems(1)
            },
            loadMoreTrigger: loadMoreTrigger,
            loadMoreItems: { _, page in
                getItems(page)
            },
            mapper: { $0 }
        )
    }
    
    public func getPage<Item>(
        errorTracker: ErrorTracker,
        loadTrigger: AnyPublisher<Void, Never>,
        reloadTrigger: AnyPublisher<Void, Never>,
        getItems: @escaping () -> AnyPublisher<PagingInfo<Item>, Error>)
        -> GetPageResult<Item> {
            
        let pageSubject = CurrentValueSubject<PagingInfo<Item>, Never>(PagingInfo<Item>())
        
        return getPage(
            pageSubject: pageSubject,
            errorTracker: errorTracker,
            loadTrigger: loadTrigger,
            getItems: { _ in
                getItems()
            },
            reloadTrigger: reloadTrigger,
            reloadItems: { _ in
                getItems()
            },
            loadMoreTrigger: Empty().eraseToAnyPublisher(),
            loadMoreItems: { _, _ in
                Empty().eraseToAnyPublisher()
            },
            mapper: { $0 }
        )
    }
    
    public func getPage<Item>(
        loadTrigger: AnyPublisher<Void, Never>,
        reloadTrigger: AnyPublisher<Void, Never>,
        getItems: @escaping () -> AnyPublisher<PagingInfo<Item>, Error>)
        -> GetPageResult<Item> {
            
            let pageSubject = CurrentValueSubject<PagingInfo<Item>, Never>(PagingInfo<Item>())
            
            return getPage(
                pageSubject: pageSubject,
                errorTracker: ErrorTracker(),
                loadTrigger: loadTrigger,
                getItems: { _ in
                    return getItems()
                },
                reloadTrigger: reloadTrigger,
                reloadItems: { _ in
                    return getItems()
                },
                loadMoreTrigger: Empty().eraseToAnyPublisher(),
                loadMoreItems: { _, _ in
                    return Empty().eraseToAnyPublisher()
                },
                mapper: { $0 }
            )
    }
}
