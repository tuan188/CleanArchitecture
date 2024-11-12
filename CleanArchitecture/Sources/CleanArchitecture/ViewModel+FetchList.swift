import Combine

/// A struct representing the configuration required to fetch a list of items.
/// This struct encapsulates the error tracker, load triggers, item fetchers, and item mapper.
public struct ListFetchConfig<TriggerInput, Item, MappedItem> {
    /// A tracker for handling and tracking errors.
    let errorTracker: ErrorTracker
    
    /// A publisher that triggers the initial load of items.
    let initialLoadTrigger: AnyPublisher<TriggerInput, Never>
    
    /// A publisher that triggers the reload of items.
    let reloadTrigger: AnyPublisher<TriggerInput, Never>
    
    /// A closure that fetches items based on the provided input.
    let fetchItems: (TriggerInput) -> AnyPublisher<[Item], Error>
    
    /// A closure that reloads items based on the provided input.
    let reloadItems: (TriggerInput) -> AnyPublisher<[Item], Error>
    
    /// A closure that maps an item to a mapped item.
    let itemMapper: (Item) -> MappedItem
    
    /// Initializes a new instance of `ListFetchConfig`.
    ///
    /// - Parameters:
    ///   - errorTracker: A tracker for handling and tracking errors.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of items.
    ///   - reloadTrigger: A publisher that triggers the reload of items.
    ///   - fetchItems: A closure that fetches items based on the provided input.
    ///   - reloadItems: A closure that reloads items based on the provided input.
    ///   - itemMapper: A closure that maps an item to a mapped item.
    public init(errorTracker: ErrorTracker,
                initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
                reloadTrigger: AnyPublisher<TriggerInput, Never>,
                fetchItems: @escaping (TriggerInput) -> AnyPublisher<[Item], Error>,
                reloadItems: @escaping (TriggerInput) -> AnyPublisher<[Item], Error>,
                itemMapper: @escaping (Item) -> MappedItem) {
        self.errorTracker = errorTracker
        self.initialLoadTrigger = initialLoadTrigger
        self.reloadTrigger = reloadTrigger
        self.fetchItems = fetchItems
        self.reloadItems = reloadItems
        self.itemMapper = itemMapper
    }
}

public extension ListFetchConfig {
    /// Initializes a new instance of `ListFetchConfig` with a default error tracker.
    /// This initializer uses the same closure for both fetching and reloading items.
    ///
    /// - Parameters:
    ///   - errorTracker: A tracker for handling and tracking errors. Defaults to a new instance of `ErrorTracker`.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of items.
    ///   - reloadTrigger: A publisher that triggers the reload of items.
    ///   - fetchItems: A closure that fetches items based on the provided input.
    ///   - itemMapper: A closure that maps an item to a mapped item.
    init(errorTracker: ErrorTracker = ErrorTracker(),
         initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         fetchItems: @escaping (TriggerInput) -> AnyPublisher<[Item], Error>,
         itemMapper: @escaping (Item) -> MappedItem) {
        self.init(errorTracker: errorTracker,
                  initialLoadTrigger: initialLoadTrigger,
                  reloadTrigger: reloadTrigger,
                  fetchItems: fetchItems,
                  reloadItems: fetchItems,
                  itemMapper: itemMapper)
    }
}

public extension ListFetchConfig where Item == MappedItem {
    /// Initializes a new instance of `ListFetchConfig` when `Item` and `MappedItem` are the same type.
    /// This initializer uses the same closure for both fetching and reloading items, and uses an identity mapper.
    ///
    /// - Parameters:
    ///   - errorTracker: A tracker for handling and tracking errors. Defaults to a new instance of `ErrorTracker`.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of items.
    ///   - reloadTrigger: A publisher that triggers the reload of items.
    ///   - fetchItems: A closure that fetches items based on the provided input.
    init(errorTracker: ErrorTracker = ErrorTracker(),
         initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         fetchItems: @escaping (TriggerInput) -> AnyPublisher<[Item], Error>) {
        self.init(errorTracker: errorTracker,
                  initialLoadTrigger: initialLoadTrigger,
                  reloadTrigger: reloadTrigger,
                  fetchItems: fetchItems,
                  reloadItems: fetchItems,
                  itemMapper: { $0 }) // Identity mapper
    }
}

/// A struct representing the result of fetching a list of items.
/// This struct encapsulates the publishers for the items, error, loading, and reloading states.
public struct FetchResult<Item> {
    /// A publisher that emits the list of items.
    public var items: AnyPublisher<[Item], Never>
    
    /// A publisher that emits errors that occur during the fetching process.
    public var error: AnyPublisher<Error, Never>
    
    /// A publisher that emits the loading state.
    public var isLoading: AnyPublisher<Bool, Never>
    
    /// A publisher that emits the reloading state.
    public var isReloading: AnyPublisher<Bool, Never>
    
    /// A tuple containing all the publishers, useful for destructuring.
    public var destructured: ( // swiftlint:disable:this large_tuple
        AnyPublisher<[Item], Never>,
        AnyPublisher<Error, Never>,
        AnyPublisher<Bool, Never>,
        AnyPublisher<Bool, Never>
    ) {
        (items, error, isLoading, isReloading)
    }
    
    /// Initializes a new instance of `FetchResult`.
    ///
    /// - Parameters:
    ///   - items: A publisher that emits the list of items.
    ///   - error: A publisher that emits errors that occur during the fetching process.
    ///   - isLoading: A publisher that emits the loading state.
    ///   - isReloading: A publisher that emits the reloading state.
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

/// Extension for ViewModel to provide a method to fetch a list of items.
extension ViewModel {
    
    /// Fetches a list of items based on the provided `ListFetchConfig`.
    ///
    /// - Parameter input: The configuration for fetching the list of items.
    /// - Returns: A `FetchResult` containing the publishers for items, error, loading, and reloading states.
    public func fetchList<TriggerInput, Item, MappedItem>(config: ListFetchConfig<TriggerInput, Item, MappedItem>)
        -> FetchResult<MappedItem> {
        
        let loadingActivityIndicator = ActivityIndicator(false)
        let reloadingActivityIndicator = ActivityIndicator(false)
        
        let items = Publishers.Merge(
                config.initialLoadTrigger.map { LoadingState.initial($0) },
                config.reloadTrigger.map { LoadingState.reload($0) }
            )
            .filter { _ in
                !loadingActivityIndicator.value && !reloadingActivityIndicator.value
            }
            .map { triggerType -> AnyPublisher<[Item], Never> in
                switch triggerType {
                case .initial(let triggerInput):
                    return config.fetchItems(triggerInput)
                        .trackError(config.errorTracker)
                        .trackActivity(loadingActivityIndicator)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                case .reload(let triggerInput):
                    return config.reloadItems(triggerInput)
                        .trackError(config.errorTracker)
                        .trackActivity(reloadingActivityIndicator)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                default:
                    return Empty().eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .map { $0.map(config.itemMapper) }
            .eraseToAnyPublisher()
        
        let error = config.errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityIndicator.eraseToAnyPublisher()
        let isReloading = reloadingActivityIndicator.eraseToAnyPublisher()
        
        return FetchResult(
            items: items,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading
        )
    }
}
