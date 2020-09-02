//
//  PagingCollectionView.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/5/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import ESPullToRefresh
import Combine
import CombineCocoa

open class PagingCollectionView: UICollectionView {
    private let _refreshControl = UIRefreshControl()
    
    open var isRefreshing: GenericSubscriber<Bool> {
        GenericSubscriber(self) { collectionView, loading in
            if collectionView.refreshHeader == nil {
                if loading {
                    collectionView._refreshControl.beginRefreshing()
                } else {
                    if collectionView._refreshControl.isRefreshing {
                        collectionView._refreshControl.endRefreshing()
                    }
                }
            } else {
                if loading {
                    collectionView.es.startPullToRefresh()
                } else {
                    collectionView.es.stopPullToRefresh()
                }
            }
        }
    }
    
    open var isLoadingMore: GenericSubscriber<Bool> {
        return GenericSubscriber(self) { collectionView, loading in
            if !loading {
                collectionView.es.stopLoadingMore()
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
