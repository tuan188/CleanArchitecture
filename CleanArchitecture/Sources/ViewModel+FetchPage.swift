import Combine

/// A struct representing the configuration required to fetch paginated items.
/// This struct encapsulates the error tracker, load triggers, item fetchers, and item mapper.
public struct PageFetchConfig<TriggerInput, Item, MappedItem> {
    /// A subject that tracks the current page of items.
    let pageSubject: CurrentValueSubject<PagingInfo<MappedItem>, Never>
    
    /// A tracker for handling and tracking errors.
    let errorTracker: ErrorTracker
    
    /// A publisher that triggers the initial load of items.
    let initialLoadTrigger: AnyPublisher<TriggerInput, Never>
    
    /// A publisher that triggers the reload of items.
    let reloadTrigger: AnyPublisher<TriggerInput, Never>
    
    /// A publisher that triggers loading more items.
    let loadMoreTrigger: AnyPublisher<TriggerInput, Never>
    
    /// A closure that fetches items based on the provided input.
    let fetchItems: (TriggerInput) -> AnyPublisher<PagingInfo<Item>, Error>
    
    /// A closure that reloads items based on the provided input.
    let reloadItems: (TriggerInput) -> AnyPublisher<PagingInfo<Item>, Error>
    
    /// A closure that loads more items based on the provided input and page number.
    let loadMoreItems: (TriggerInput, Int) -> AnyPublisher<PagingInfo<Item>, Error>
    
    /// A closure that maps an item to a mapped item.
    let itemMapper: (Item) -> MappedItem
    
    /// Initializes a new instance of `PageFetchConfig`.
    ///
    /// - Parameters:
    ///   - pageSubject: A subject that tracks the current page of items.
    ///   - errorTracker: A tracker for handling and tracking errors.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of items.
    ///   - reloadTrigger: A publisher that triggers the reload of items.
    ///   - loadMoreTrigger: A publisher that triggers loading more items.
    ///   - fetchItems: A closure that fetches items based on the provided input.
    ///   - reloadItems: A closure that reloads items based on the provided input.
    ///   - loadMoreItems: A closure that loads more items based on the provided input and page number.
    ///   - itemMapper: A closure that maps an item to a mapped item.
    public init(pageSubject: CurrentValueSubject<PagingInfo<MappedItem>, Never>,
                errorTracker: ErrorTracker,
                initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
                reloadTrigger: AnyPublisher<TriggerInput, Never>,
                loadMoreTrigger: AnyPublisher<TriggerInput, Never>,
                fetchItems: @escaping (TriggerInput) -> AnyPublisher<PagingInfo<Item>, Error>,
                reloadItems: @escaping (TriggerInput) -> AnyPublisher<PagingInfo<Item>, Error>,
                loadMoreItems: @escaping (TriggerInput, Int) -> AnyPublisher<PagingInfo<Item>, Error>,
                itemMapper: @escaping (Item) -> MappedItem) {
        self.pageSubject = pageSubject
        self.errorTracker = errorTracker
        self.initialLoadTrigger = initialLoadTrigger
        self.reloadTrigger = reloadTrigger
        self.loadMoreTrigger = loadMoreTrigger
        self.fetchItems = fetchItems
        self.reloadItems = reloadItems
        self.loadMoreItems = loadMoreItems
        self.itemMapper = itemMapper
    }
}

public extension PageFetchConfig {
    /// Initializes a new instance of `PageFetchConfig` with default values for pageSubject and errorTracker.
    /// This initializer uses the same closure for fetching and reloading items.
    ///
    /// - Parameters:
    ///   - pageSubject: A subject that tracks the current page of items.
    ///   - errorTracker: A tracker for handling and tracking errors.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of items.
    ///   - reloadTrigger: A publisher that triggers the reload of items.
    ///   - loadMoreTrigger: A publisher that triggers loading more items.
    ///   - fetchItems: A closure that fetches items based on the provided input and page number.
    ///   - itemMapper: A closure that maps an item to a mapped item.
    init(pageSubject: CurrentValueSubject<PagingInfo<MappedItem>, Never> = CurrentValueSubject<PagingInfo<MappedItem>, Never>(PagingInfo<MappedItem>()),
         errorTracker: ErrorTracker = ErrorTracker(),
         initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         loadMoreTrigger: AnyPublisher<TriggerInput, Never>,
         fetchItems: @escaping (TriggerInput, Int) -> AnyPublisher<PagingInfo<Item>, Error>,
         itemMapper: @escaping (Item) -> MappedItem) {
        self.init(pageSubject: pageSubject,
                  errorTracker: errorTracker,
                  initialLoadTrigger: initialLoadTrigger,
                  reloadTrigger: reloadTrigger,
                  loadMoreTrigger: loadMoreTrigger,
                  fetchItems: { triggerInput in fetchItems(triggerInput, 1) },
                  reloadItems: { triggerInput in fetchItems(triggerInput, 1) },
                  loadMoreItems: fetchItems,
                  itemMapper: itemMapper)
    }
}

public extension PageFetchConfig where TriggerInput == Void {
    /// Initializes a new instance of `PageFetchConfig` for Void TriggerInput with default values for pageSubject and errorTracker.
    /// This initializer uses the same closure for fetching and reloading items.
    ///
    /// - Parameters:
    ///   - pageSubject: A subject that tracks the current page of items.
    ///   - errorTracker: A tracker for handling and tracking errors.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of items.
    ///   - reloadTrigger: A publisher that triggers the reload of items.
    ///   - loadMoreTrigger: A publisher that triggers loading more items.
    ///   - fetchItems: A closure that fetches items based on the page number.
    ///   - itemMapper: A closure that maps an item to a mapped item.
    init(pageSubject: CurrentValueSubject<PagingInfo<MappedItem>, Never> = CurrentValueSubject<PagingInfo<MappedItem>, Never>(PagingInfo<MappedItem>()),
         errorTracker: ErrorTracker = ErrorTracker(),
         initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         loadMoreTrigger: AnyPublisher<TriggerInput, Never>,
         fetchItems: @escaping (Int) -> AnyPublisher<PagingInfo<Item>, Error>,
         itemMapper: @escaping (Item) -> MappedItem) {
        self.init(pageSubject: pageSubject,
                  errorTracker: errorTracker,
                  initialLoadTrigger: initialLoadTrigger,
                  reloadTrigger: reloadTrigger,
                  loadMoreTrigger: loadMoreTrigger,
                  fetchItems: { _ in fetchItems(1) },
                  reloadItems: { _ in fetchItems(1) },
                  loadMoreItems: { _, page in fetchItems(page) },
                  itemMapper: itemMapper)
    }
}

public extension PageFetchConfig where Item == MappedItem {
    /// Initializes a new instance of `PageFetchConfig` for when Item and MappedItem are the same type.
    /// This initializer uses the same closure for fetching and reloading items.
    ///
    /// - Parameters:
    ///   - pageSubject: A subject that tracks the current page of items.
    ///   - errorTracker: A tracker for handling and tracking errors.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of items.
    ///   - reloadTrigger: A publisher that triggers the reload of items.
    ///   - loadMoreTrigger: A publisher that triggers loading more items.
    ///   - fetchItems: A closure that fetches items based on the provided input and page number.
    init(pageSubject: CurrentValueSubject<PagingInfo<MappedItem>, Never> = CurrentValueSubject<PagingInfo<MappedItem>, Never>(PagingInfo<MappedItem>()),
         errorTracker: ErrorTracker = ErrorTracker(),
         initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         loadMoreTrigger: AnyPublisher<TriggerInput, Never>,
         fetchItems: @escaping (TriggerInput, Int) -> AnyPublisher<PagingInfo<Item>, Error>) {
        self.init(pageSubject: pageSubject,
                  errorTracker: errorTracker,
                  initialLoadTrigger: initialLoadTrigger,
                  reloadTrigger: reloadTrigger,
                  loadMoreTrigger: loadMoreTrigger,
                  fetchItems: { triggerInput in fetchItems(triggerInput, 1) },
                  reloadItems: { triggerInput in fetchItems(triggerInput, 1) },
                  loadMoreItems: fetchItems,
                  itemMapper: { $0 })
    }
}

public extension PageFetchConfig where Item == MappedItem, TriggerInput == Void {
    /// Initializes a new instance of `PageFetchConfig` for Void TriggerInput and when Item and MappedItem are the same type.
    /// This initializer uses the same closure for fetching and reloading items.
    ///
    /// - Parameters:
    ///   - pageSubject: A subject that tracks the current page of items.
    ///   - errorTracker: A tracker for handling and tracking errors.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of items.
    ///   - reloadTrigger: A publisher that triggers the reload of items.
    ///   - loadMoreTrigger: A publisher that triggers loading more items.
    ///   - fetchItems: A closure that fetches items based on the page number.
    init(pageSubject: CurrentValueSubject<PagingInfo<MappedItem>, Never> = CurrentValueSubject<PagingInfo<MappedItem>, Never>(PagingInfo<MappedItem>()),
         errorTracker: ErrorTracker = ErrorTracker(),
         initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         loadMoreTrigger: AnyPublisher<TriggerInput, Never>,
         fetchItems: @escaping (Int) -> AnyPublisher<PagingInfo<Item>, Error>) {
        self.init(pageSubject: pageSubject,
                  errorTracker: errorTracker,
                  initialLoadTrigger: initialLoadTrigger,
                  reloadTrigger: reloadTrigger,
                  loadMoreTrigger: loadMoreTrigger,
                  fetchItems: { _ in fetchItems(1) },
                  reloadItems: { _ in fetchItems(1) },
                  loadMoreItems: { _, page in fetchItems(page) },
                  itemMapper: { $0 })
    }
}

/// A struct representing the result of fetching paginated items.
/// This struct encapsulates the publishers for the page, error, loading, reloading, and loading more states.
public struct PageFetchResult<Item> {
    /// A publisher that emits the current page of items.
    public var page: AnyPublisher<PagingInfo<Item>, Never>
    
    /// A publisher that emits errors that occur during the fetching process.
    public var error: AnyPublisher<Error, Never>
    
    /// A publisher that emits the loading state.
    public var isLoading: AnyPublisher<Bool, Never>
    
    /// A publisher that emits the reloading state.
    public var isReloading: AnyPublisher<Bool, Never>
    
    /// A publisher that emits the loading more state.
    public var isLoadingMore: AnyPublisher<Bool, Never>
    
    /// A tuple containing all the publishers, useful for destructuring.
    public var destructured: (  // swiftlint:disable:this large_tuple
        AnyPublisher<PagingInfo<Item>, Never>,
        AnyPublisher<Error, Never>,
        AnyPublisher<Bool, Never>,
        AnyPublisher<Bool, Never>,
        AnyPublisher<Bool, Never>
    ) {
        (page, error, isLoading, isReloading, isLoadingMore)
    }
    
    /// Initializes a new instance of `PageFetchResult`.
    ///
    /// - Parameters:
    ///   - page: A publisher that emits the current page of items.
    ///   - error: A publisher that emits errors that occur during the fetching process.
    ///   - isLoading: A publisher that emits the loading state.
    ///   - isReloading: A publisher that emits the reloading state.
    ///   - isLoadingMore: A publisher that emits the loading more state.
    public init(page: AnyPublisher<PagingInfo<Item>, Never>,
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

public extension ViewModel {
    /// Fetches paginated items based on the provided `PageFetchConfig`.
    ///
    /// - Parameter config: The configuration for fetching the paginated items.
    /// - Returns: A `PageFetchResult` containing the publishers for the page, error, loading, reloading, and loading more states.
    func fetchPage<TriggerInput, Item, MappedItem>(config: PageFetchConfig<TriggerInput, Item, MappedItem>)
        -> PageFetchResult<MappedItem> {
        
        let loadingActivityTracker = ActivityIndicator(false)
        let reloadingActivityTracker = ActivityIndicator(false)
        let loadingMoreActivityTracker = ActivityIndicator(false)
        let loadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
        
        let loadItems = Publishers.Merge(
                config.initialLoadTrigger.map { LoadingState.initial($0) },
                config.reloadTrigger.map { LoadingState.reload($0) }
            )
            .filter { _ in
                !loadingActivityTracker.value && !reloadingActivityTracker.value
            }
            .map { triggerType -> AnyPublisher<PagingInfo<Item>, Never> in
                switch triggerType {
                case .initial(let triggerInput):
                    return config.fetchItems(triggerInput)
                        .trackError(config.errorTracker)
                        .trackActivity(loadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                case .reload(let triggerInput):
                    return config.reloadItems(triggerInput)
                        .trackError(config.errorTracker)
                        .trackActivity(reloadingActivityTracker)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                default:
                    return Empty().eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .handleEvents(receiveOutput: { page in
                let newPage = PagingInfo<MappedItem>(
                    page: page.page,
                    items: page.items.map(config.itemMapper),
                    hasMorePages: page.hasMorePages,
                    totalItems: page.totalItems,
                    itemsPerPage: page.itemsPerPage,
                    totalPages: page.totalPages
                )
                config.pageSubject.send(newPage)
            })
        
        let loadMoreItems = config.loadMoreTrigger
            .filter { _ in
                !loadingActivityTracker.value
                    && !reloadingActivityTracker.value
                    && !(loadingMoreActivityTracker.value || loadingMoreSubject.value)
            }
            .handleEvents(receiveOutput: { _ in
                if config.pageSubject.value.items.isEmpty {
                    loadingMoreSubject.send(false)
                }
            })
            .filter { _ in !config.pageSubject.value.items.isEmpty }
            .map { triggerInput -> AnyPublisher<PagingInfo<Item>, Never> in
                let page = config.pageSubject.value.page
                return config.loadMoreItems(triggerInput, page + 1)
                    .trackError(config.errorTracker)
                    .trackActivity(loadingMoreActivityTracker)
                    .catch { _ in Empty() }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .filter { !$0.items.isEmpty || !$0.hasMorePages }
            .handleEvents(receiveOutput: { page in
                let currentPage = config.pageSubject.value
                let items = currentPage.items + page.items.map(config.itemMapper)
                let newPage = PagingInfo<MappedItem>(
                    page: page.page,
                    items: items,
                    hasMorePages: page.hasMorePages,
                    totalItems: page.totalItems,
                    itemsPerPage: page.itemsPerPage,
                    totalPages: page.totalPages
                )
                config.pageSubject.send(newPage)
            })
        
        let page = Publishers.Merge(loadItems, loadMoreItems)
            .map { _ in config.pageSubject.value }
            .eraseToAnyPublisher()
        
        let error = config.errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityTracker.eraseToAnyPublisher()
        let isReloading = reloadingActivityTracker.eraseToAnyPublisher()
        let isLoadingMore = loadingMoreActivityTracker.eraseToAnyPublisher()
        
        return PageFetchResult(
            page: page,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading,
            isLoadingMore: isLoadingMore
        )
    }
}
