import UIKit
import ESPullToRefresh
import Combine
import CombineCocoa
import CleanArchitecture

/// A `UITableView` subclass that integrates pull-to-refresh and load-more functionality.
open class PagingTableView: UITableView {
    
    private let _refreshControl = UIRefreshControl()
    private var _refreshTrigger = PassthroughSubject<Void, Never>()
    private var _loadMoreTrigger = PassthroughSubject<Void, Never>()
    
    /// A subscriber that controls the refreshing state of the table view.
    /// - The subscriber will begin or end the refreshing state based on the provided `Bool` value.
    /// - When `true`, the refresh control will start refreshing. When `false`, the refresh control will stop.
    open var isRefreshing: GenericSubscriber<Bool> {
        GenericSubscriber(self) { tableView, loading in
            if tableView.refreshHeader == nil {
                if loading {
                    tableView._refreshControl.beginRefreshing()
                } else {
                    if tableView._refreshControl.isRefreshing {
                        tableView._refreshControl.endRefreshing()
                    }
                }
            } else {
                if loading {
                    tableView.es.startPullToRefresh()
                } else {
                    tableView.es.stopPullToRefresh()
                }
            }
        }
    }
    
    /// A subscriber that controls the loading more state of the table view.
    /// - The subscriber will start or stop the loading-more state based on the provided `Bool` value.
    /// - When `true`, the load-more control will start refreshing. When `false`, it will stop.
    open var isLoadingMore: GenericSubscriber<Bool> {
        return GenericSubscriber(self) { tableView, loading in
            if loading {
                tableView.es.base.footer?.startRefreshing()
            } else {
                tableView.es.stopLoadingMore()
            }
        }
    }
    
    /// A publisher that emits events when a refresh is triggered.
    /// - Emits a `Void` event when a refresh is initiated, either through a user action or programmatically.
    /// - This publisher uses a combination of `_refreshTrigger` and `UIRefreshControl`'s `isRefreshing` state.
    open var refreshTrigger: AnyPublisher<Void, Never> {
        return Publishers.Merge(
            _refreshTrigger
                .filter { [weak self] in
                    self?.refreshControl == nil
                },
            _refreshControl.isRefreshingPublisher
                .filter { [weak self] in
                    $0 && self?.refreshControl != nil
                }
                .map { _ in }
        )
        .eraseToAnyPublisher()
    }
    
    /// A publisher that emits events when loading more is triggered.
    /// - Emits a `Void` event when the load-more functionality is initiated, typically when reaching the end of the table view content.
    open var loadMoreTrigger: AnyPublisher<Void, Never> {
        _loadMoreTrigger.eraseToAnyPublisher()
    }
    
    /// The custom refresh header for pull-to-refresh functionality, conforming to both `ESRefreshProtocol` and `ESRefreshAnimatorProtocol`.
    /// - When set, this header replaces the default `UIRefreshControl` and adds custom pull-to-refresh functionality.
    open var refreshHeader: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            guard let header = refreshHeader else { return }
            es.addPullToRefresh(animator: header) { [weak self] in
                self?._refreshTrigger.send(())
            }
            removeRefreshControl()
        }
    }
    
    /// The custom refresh footer for load-more functionality, conforming to both `ESRefreshProtocol` and `ESRefreshAnimatorProtocol`.
    /// - When set, this footer enables load-more functionality at the bottom of the table view.
    open var refreshFooter: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            guard let footer = refreshFooter else { return }
            es.addInfiniteScrolling(animator: footer) { [weak self] in
                self?._loadMoreTrigger.send()
            }
        }
    }
    
    /// Initializes the table view and sets up default refresh and load-more behaviors.
    override open func awakeFromNib() {
        super.awakeFromNib()
        expiredTimeInterval = 20.0
        addRefreshControl()
        refreshFooter = RefreshFooterAnimator(frame: .zero)
    }
    
    /// Adds the default `UIRefreshControl` to the table view for pull-to-refresh functionality.
    /// - This method is called by `awakeFromNib` and can be used to re-enable the system refresh control.
    func addRefreshControl() {
        refreshHeader = nil
        self.refreshControl = _refreshControl
    }
    
    /// Removes the default `UIRefreshControl` from the table view.
    /// - This method is called when a custom `refreshHeader` is set to replace the default control.
    func removeRefreshControl() {
        self.refreshControl = nil
    }
}
