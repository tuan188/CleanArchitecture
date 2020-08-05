//
//  RefreshAutoHeader.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/4/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import MJRefresh

open class RefreshAutoHeader: MJRefreshHeader {
    open var activityIndicatorViewStyle: UIActivityIndicatorView.Style! {
        didSet {
            _loadingView = nil
            setNeedsLayout()
        }
    }
    
    private var _loadingView: UIActivityIndicatorView?
    
    open var loadingView: UIActivityIndicatorView {
        guard let loadingView = _loadingView else {
            let view = UIActivityIndicatorView(style: self.activityIndicatorViewStyle)
            view.hidesWhenStopped = true
            self.addSubview(view)
            _loadingView = view
            return view
        }
        
        return loadingView
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            activityIndicatorViewStyle = .medium
        } else {
            activityIndicatorViewStyle = .gray
        }
    }
    
    override open func prepare() {
        super.prepare()
        
        if #available(iOS 13.0, *) {
            activityIndicatorViewStyle = .medium
        } else {
            activityIndicatorViewStyle = .gray
        }
    }
    
    override open func placeSubviews() {
        super.placeSubviews()
        
        let center = CGPoint(x: mj_w * 0.5, y: mj_h * 0.5)
        
        if loadingView.constraints.isEmpty {
            loadingView.center = center
        }
    }
    
    override open var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                if oldValue == .refreshing {
                    UIView.animate(
                        withDuration: TimeInterval(MJRefreshSlowAnimationDuration),
                        animations: {
                            self.loadingView.alpha = 0
                        }, completion: { _ in
                            self.loadingView.alpha = 1
                            self.loadingView.stopAnimating()
                        })
                } else {
                    loadingView.stopAnimating()
                }
            case .pulling:
                loadingView.startAnimating()
            case .refreshing:
                loadingView.startAnimating()
            case .noMoreData:
                loadingView.stopAnimating()
            default:
                break
            }
        }
    }
}
