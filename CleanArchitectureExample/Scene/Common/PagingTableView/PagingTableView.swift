//
//  PagingTableView.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/4/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import ESPullToRefresh
import Combine
import CombineCocoa

open class PagingTableView: UITableView {
    private let _refreshControl = UIRefreshControl()
    
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
    
    open var isLoadingMore: GenericSubscriber<Bool> {
        return GenericSubscriber(self) { tableView, loading in
            if loading {
                tableView.es.base.footer?.startRefreshing()
            } else {
                tableView.es.stopLoadingMore()
            }
        }
    }
    
    private var _refreshTrigger = PassthroughSubject<Void, Never>()
    
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
    
    private var _loadMoreTrigger = PassthroughSubject<Void, Never>()
    
    open var loadMoreTrigger: AnyPublisher<Void, Never> {
        _loadMoreTrigger.eraseToAnyPublisher()
    }
    
    open var refreshHeader: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            guard let header = refreshHeader else { return }
            es.addPullToRefresh(animator: header) { [weak self] in
                self?._refreshTrigger.send(())
            }
            removeRefreshControl()
        }
    }
    
    open var refreshFooter: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            guard let footer = refreshFooter else { return }
            es.addInfiniteScrolling(animator: footer) { [weak self] in
                self?._loadMoreTrigger.send()
            }
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        expiredTimeInterval = 20.0
        addRefreshControl()
        refreshFooter = RefreshFooterAnimator(frame: .zero)
    }
    
    func addRefreshControl() {
        refreshHeader = nil
        self.refreshControl = _refreshControl
    }
    
    func removeRefreshControl() {
        self.refreshControl = nil
    }
}
