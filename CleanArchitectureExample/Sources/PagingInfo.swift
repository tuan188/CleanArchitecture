/// A struct representing paginated information for a collection of items.
/// This struct encapsulates details about the current page, the items, and pagination metadata.
public struct PagingInfo<T> {
    /// The current page number.
    public var page: Int
    
    /// The items on the current page.
    public var items: [T]
    
    /// A flag indicating whether there are more pages available.
    public var hasMorePages: Bool
    
    /// The total number of items available across all pages.
    public var totalItems: Int
    
    /// The number of items per page.
    public var itemsPerPage: Int
    
    /// The total number of pages available.
    public var totalPages: Int
    
    /// Initializes a new instance of `PagingInfo` with full pagination details.
    ///
    /// - Parameters:
    ///   - page: The current page number.
    ///   - items: The items on the current page.
    ///   - hasMorePages: A flag indicating whether there are more pages available.
    ///   - totalItems: The total number of items available across all pages.
    ///   - itemsPerPage: The number of items per page.
    ///   - totalPages: The total number of pages available.
    public init(page: Int,
                items: [T],
                hasMorePages: Bool,
                totalItems: Int,
                itemsPerPage: Int,
                totalPages: Int) {
        self.page = page
        self.items = items
        self.hasMorePages = hasMorePages
        self.totalItems = totalItems
        self.itemsPerPage = itemsPerPage
        self.totalPages = totalPages
    }
    
    /// Initializes a new instance of `PagingInfo` with basic pagination details.
    ///
    /// - Parameters:
    ///   - page: The current page number.
    ///   - items: The items on the current page.
    ///   - hasMorePages: A flag indicating whether there are more pages available.
    public init(page: Int, items: [T], hasMorePages: Bool) {
        self.init(page: page,
                  items: items,
                  hasMorePages: hasMorePages,
                  totalItems: 0,
                  itemsPerPage: 0,
                  totalPages: 0)
    }
    
    /// Initializes a new instance of `PagingInfo` with the current page and items.
    ///
    /// - Parameters:
    ///   - page: The current page number.
    ///   - items: The items on the current page.
    public init(page: Int, items: [T]) {
        self.init(page: page,
                  items: items,
                  hasMorePages: true,
                  totalItems: 0,
                  itemsPerPage: 0,
                  totalPages: 0)
    }
    
    /// Initializes a new instance of `PagingInfo` with default values.
    /// This initializer sets the current page to 1, an empty items array, and assumes more pages are available.
    public init() {
        self.init(page: 1,
                  items: [],
                  hasMorePages: true,
                  totalItems: 0,
                  itemsPerPage: 0,
                  totalPages: 0)
    }
}

extension PagingInfo: Equatable where T: Equatable {
    /// Conformance to the Equatable protocol for PagingInfo when the items are Equatable.
    /// This allows two PagingInfo instances to be compared for equality based on their properties.
}
