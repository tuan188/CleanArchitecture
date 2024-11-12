//
//  RefreshFooterAnimator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/4/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import ESPullToRefresh

open class RefreshFooterAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    
    open var view: UIView { return self }
    open var duration: TimeInterval = 0.3
    open var insets = UIEdgeInsets.zero
    open var trigger: CGFloat = 42.0
    open var executeIncremental: CGFloat = 42.0
    open var state: ESRefreshViewState = .pullToRefresh
    
    fileprivate let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.isHidden = true
        return indicatorView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicatorView)
    }
    
    // swiftlint:disable:next unavailable_function
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func refreshAnimationBegin(view: ESRefreshComponent) {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
    }
    
    open func refreshAnimationEnd(view: ESRefreshComponent) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }
    
    open func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        // do nothing
    }
    
    open func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        self.setNeedsLayout()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let s = self.bounds.size
        let w = s.width
        let h = s.height
        
        indicatorView.center = CGPoint(x: w / 2.0, y: h / 2.0 - 5.0)
    }
}
