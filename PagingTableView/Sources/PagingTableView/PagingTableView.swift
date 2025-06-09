import UIKit
import Combine
import CombineCocoa
import CleanArchitecture
import MJRefresh

/// A `UITableView` subclass that integrates pull-to-refresh and load-more functionality.
open class PagingTableView: UITableView {
    open var isRefreshing: GenericSubscriber<Bool> {
        GenericSubscriber(self) { tableView, loading in
            if loading {
                tableView.mj_header?.beginRefreshing()
            } else {
                tableView.mj_header?.endRefreshing()
            }
        }
    }
    
    open var isLoadingMore: GenericSubscriber<Bool> {
        GenericSubscriber(self) { tableView, loading in
            if loading {
                tableView.mj_footer?.beginRefreshing()
            } else {
                tableView.mj_footer?.endRefreshing()
            }
        }
    }
    
    private var _loadMoreTopTrigger = PassthroughSubject<Void, Never>()
    
    open var refreshTrigger: AnyPublisher<Void, Never> {
        _loadMoreTopTrigger.eraseToAnyPublisher()
    }
    
    private var _loadMoreBottomTrigger = PassthroughSubject<Void, Never>()
    
    open var loadMoreTrigger: AnyPublisher<Void, Never> {
        return _loadMoreBottomTrigger.eraseToAnyPublisher()
    }
    
    open var refreshHeader: MJRefreshHeader? {
        didSet {
            mj_header = refreshHeader
            mj_header?.refreshingBlock = { [weak self] in
                self?._loadMoreTopTrigger.send(())
            }
        }
    }
    
    open var refreshFooter: MJRefreshFooter? {
        didSet {
            mj_footer = refreshFooter
            mj_footer?.refreshingBlock = { [weak self] in
                self?._loadMoreBottomTrigger.send(())
            }
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.refreshHeader = RefreshAutoHeader()
        self.refreshFooter = RefreshAutoFooter()
    }
    
    open func removeRefreshFooter() {
        refreshFooter = nil
    }
}
