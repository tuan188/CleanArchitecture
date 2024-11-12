import Combine

/// A struct representing the configuration required to fetch a single item.
/// This struct encapsulates the error tracker, load triggers, and item fetchers.
public struct FetchItemConfig<TriggerInput, Item> {
    /// A tracker for handling and tracking errors.
    let errorTracker: ErrorTracker
    
    /// A publisher that triggers the initial load of the item.
    let initialLoadTrigger: AnyPublisher<TriggerInput, Never>
    
    /// A publisher that triggers the reload of the item.
    let reloadTrigger: AnyPublisher<TriggerInput, Never>
    
    /// A closure that fetches the item based on the provided input.
    let fetchItem: (TriggerInput) -> AnyPublisher<Item, Error>
    
    /// A closure that reloads the item based on the provided input.
    let reloadItem: (TriggerInput) -> AnyPublisher<Item, Error>
    
    /// Initializes a new instance of `FetchItemConfig`.
    ///
    /// - Parameters:
    ///   - errorTracker: A tracker for handling and tracking errors.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of the item.
    ///   - reloadTrigger: A publisher that triggers the reload of the item.
    ///   - fetchItem: A closure that fetches the item based on the provided input.
    ///   - reloadItem: A closure that reloads the item based on the provided input.
    public init(errorTracker: ErrorTracker,
                initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
                fetchItem: @escaping (TriggerInput) -> AnyPublisher<Item, Error>,
                reloadTrigger: AnyPublisher<TriggerInput, Never>,
                reloadItem: @escaping (TriggerInput) -> AnyPublisher<Item, Error>) {
        self.errorTracker = errorTracker
        self.initialLoadTrigger = initialLoadTrigger
        self.reloadTrigger = reloadTrigger
        self.fetchItem = fetchItem
        self.reloadItem = reloadItem
    }
}

public extension FetchItemConfig {
    /// Initializes a new instance of `FetchItemConfig` with a default error tracker.
    /// This initializer uses the same closure for both fetching and reloading the item.
    ///
    /// - Parameters:
    ///   - errorTracker: A tracker for handling and tracking errors. Defaults to a new instance of `ErrorTracker`.
    ///   - initialLoadTrigger: A publisher that triggers the initial load of the item.
    ///   - reloadTrigger: A publisher that triggers the reload of the item.
    ///   - fetchItem: A closure that fetches the item based on the provided input.
    init(errorTracker: ErrorTracker = ErrorTracker(),
         initialLoadTrigger: AnyPublisher<TriggerInput, Never>,
         reloadTrigger: AnyPublisher<TriggerInput, Never>,
         fetchItem: @escaping (TriggerInput) -> AnyPublisher<Item, Error>) {
        self.init(errorTracker: errorTracker,
                  initialLoadTrigger: initialLoadTrigger,
                  fetchItem: fetchItem,
                  reloadTrigger: reloadTrigger,
                  reloadItem: fetchItem)
    }
}

/// A struct representing the result of fetching a single item.
/// This struct encapsulates the publishers for the item, error, loading, and reloading states.
public struct FetchItemResult<Item> {
    /// A publisher that emits the item.
    public var item: AnyPublisher<Item, Never>
    
    /// A publisher that emits errors that occur during the fetching process.
    public var error: AnyPublisher<Error, Never>
    
    /// A publisher that emits the loading state.
    public var isLoading: AnyPublisher<Bool, Never>
    
    /// A publisher that emits the reloading state.
    public var isReloading: AnyPublisher<Bool, Never>
    
    /// A tuple containing all the publishers, useful for destructuring.
    public var destructured: (  // swiftlint:disable:this large_tuple
        AnyPublisher<Item, Never>,
        AnyPublisher<Error, Never>,
        AnyPublisher<Bool, Never>,
        AnyPublisher<Bool, Never>
    ) {
        (item, error, isLoading, isReloading)
    }
    
    /// Initializes a new instance of `FetchItemResult`.
    ///
    /// - Parameters:
    ///   - item: A publisher that emits the item.
    ///   - error: A publisher that emits errors that occur during the fetching process.
    ///   - isLoading: A publisher that emits the loading state.
    ///   - isReloading: A publisher that emits the reloading state.
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

/// Extension for ViewModel to provide a method to fetch a single item.
extension ViewModel {
    
    /// Fetches a single item based on the provided `FetchItemConfig`.
    ///
    /// - Parameter config: The configuration for fetching the item.
    /// - Returns: A `FetchItemResult` containing the publishers for the item, error, loading, and reloading states.
    public func fetchItem<TriggerInput, Item>(config: FetchItemConfig<TriggerInput, Item>) -> FetchItemResult<Item> {
        
        let loadingActivityIndicator = ActivityIndicator(false)
        let reloadingActivityIndicator = ActivityIndicator(false)
        
        let item = Publishers.Merge(
                config.initialLoadTrigger.map { LoadingState.initial($0) },
                config.reloadTrigger.map { LoadingState.reload($0) }
            )
            .filter { _ in
                !loadingActivityIndicator.value && !reloadingActivityIndicator.value
            }
            .map { triggerType -> AnyPublisher<Item, Never> in
                switch triggerType {
                case .initial(let triggerInput):
                    return config.fetchItem(triggerInput)
                        .trackError(config.errorTracker)
                        .trackActivity(loadingActivityIndicator)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                case .reload(let triggerInput):
                    return config.reloadItem(triggerInput)
                        .trackError(config.errorTracker)
                        .trackActivity(reloadingActivityIndicator)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher()
                default:
                    return Empty().eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
            
        let error = config.errorTracker.eraseToAnyPublisher()
        let isLoading = loadingActivityIndicator.eraseToAnyPublisher()
        let isReloading = reloadingActivityIndicator.eraseToAnyPublisher()
        
        return FetchItemResult(
            item: item,
            error: error,
            isLoading: isLoading,
            isReloading: isReloading
        )
    }
}
