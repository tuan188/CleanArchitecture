import UIKit
import ESPullToRefresh
import Combine
import CombineCocoa
import CleanArchitecture

/// A `UICollectionView` subclass that provides pull-to-refresh and load-more functionality.
open class PagingCollectionView: UICollectionView {
    
    private let _refreshControl = UIRefreshControl()
    private var _refreshTrigger = PassthroughSubject<Void, Never>()
    private var _loadMoreTrigger = PassthroughSubject<Void, Never>()
    
    /// A subscriber that controls the refreshing state of the collection view.
    /// - When `true`, the refresh control begins refreshing; when `false`, it stops.
    /// - If a custom refresh header is set, it uses the ESPullToRefresh control instead of the default UIRefreshControl.
    open var isRefreshing: GenericSubscriber<Bool> {
        GenericSubscriber(self) { collectionView, loading in
            if collectionView.refreshHeader == nil {
                if loading {
                    collectionView._refreshControl.beginRefreshing()
                } else if collectionView._refreshControl.isRefreshing {
                    collectionView._refreshControl.endRefreshing()
                }
            } else {
                loading ? collectionView.es.startPullToRefresh() : collectionView.es.stopPullToRefresh()
            }
        }
    }
    
    /// A subscriber that controls the loading more state of the collection view.
    /// - When `true`, the load-more control begins refreshing; when `false`, it stops.
    open var isLoadingMore: GenericSubscriber<Bool> {
        GenericSubscriber(self) { collectionView, loading in
            loading ? collectionView.es.base.footer?.startRefreshing() : collectionView.es.stopLoadingMore()
        }
    }
    
    /// A publisher that emits events when a refresh is triggered.
    /// - Emits a `Void` event whenever a refresh action is triggered, whether through a system control or programmatically.
    open var refreshTrigger: AnyPublisher<Void, Never> {
        Publishers.Merge(
            _refreshTrigger
                .filter { [weak self] in self?.refreshControl == nil },
            _refreshControl.isRefreshingPublisher
                .filter { [weak self] in $0 && self?.refreshControl != nil }
                .map { _ in }
        )
        .eraseToAnyPublisher()
    }
    
    /// A publisher that emits events when loading more is triggered.
    /// - Emits a `Void` event whenever the load-more functionality is activated.
    open var loadMoreTrigger: AnyPublisher<Void, Never> {
        _loadMoreTrigger.eraseToAnyPublisher()
    }
    
    /// The custom refresh header for pull-to-refresh functionality, conforming to both `ESRefreshProtocol` and `ESRefreshAnimatorProtocol`.
    /// - When set, this header replaces the default `UIRefreshControl` and enables customized pull-to-refresh animations and behaviors.
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
    /// - When set, this footer enables load-more functionality at the bottom of the collection view.
    open var refreshFooter: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            guard let footer = refreshFooter else { return }
            es.addInfiniteScrolling(animator: footer) { [weak self] in
                self?._loadMoreTrigger.send()
            }
        }
    }

    /// Initializes the collection view and sets up default refresh and load-more controls.
    override open func awakeFromNib() {
        super.awakeFromNib()
        addRefreshControl()
        refreshFooter = RefreshFooterAnimator(frame: .zero)
    }
    
    /// Adds the default `UIRefreshControl` to the collection view for pull-to-refresh functionality.
    /// - This method is called by `awakeFromNib` and can be used to re-enable the system refresh control if needed.
    func addRefreshControl() {
        refreshHeader = nil
        self.refreshControl = _refreshControl
    }
    
    /// Removes the default `UIRefreshControl` from the collection view.
    /// - This method is called when a custom `refreshHeader` is set to replace the default control.
    func removeRefreshControl() {
        self.refreshControl = nil
    }
}
