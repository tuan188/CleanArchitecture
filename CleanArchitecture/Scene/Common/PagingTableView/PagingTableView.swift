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
            if !loading {
                tableView.es.stopLoadingMore()
            }
        }
    }
    
    private var _refreshTrigger = PassthroughSubject<Void, Never>()
    
    open var refreshTrigger: AnyPublisher<Void, Never> {
        if refreshHeader == nil {
            return _refreshControl.isRefreshingPublisher
                .map { _ in }
                .eraseToAnyPublisher()
        } else {
            return _refreshTrigger.eraseToAnyPublisher()
        }
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
        addSubview(_refreshControl)
        refreshFooter = ESRefreshFooterAnimator(frame: .zero)
    }
    
    func addRefreshControl() {
        guard !self.subviews.contains(_refreshControl) else { return }
        
        refreshHeader = nil
        addSubview(_refreshControl)
    }
    
    func removeRefreshControl() {
        _refreshControl.removeFromSuperview()
    }
}
