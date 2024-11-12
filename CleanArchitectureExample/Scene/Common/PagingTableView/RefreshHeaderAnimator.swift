//
//  RefreshHeaderAnimator.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/4/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import ESPullToRefresh

open class RefreshHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol, ESRefreshImpactProtocol {
    open var view: UIView { return self }
    open var insets = UIEdgeInsets.zero
    open var trigger: CGFloat = 60.0
    open var executeIncremental: CGFloat = 60.0
    open var state: ESRefreshViewState = .pullToRefresh
    
    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView()
        let frameworkBundle = Bundle(for: ESRefreshAnimator.self)
        if /* CocoaPods static */ let path = frameworkBundle.path(forResource: "ESPullToRefresh", ofType: "bundle"),
            let bundle = Bundle(path: path) {
            imageView.image = UIImage(named: "icon_pull_to_refresh_arrow", in: bundle, compatibleWith: nil)
        } else if /* Carthage */ let bundle = Bundle(identifier: "com.eggswift.ESPullToRefresh") {
            imageView.image = UIImage(named: "icon_pull_to_refresh_arrow", in: bundle, compatibleWith: nil)
        } else if /* CocoaPods */ let bundle = Bundle(identifier: "org.cocoapods.ESPullToRefresh") {
            imageView.image = UIImage(named: "ESPullToRefresh.bundle/icon_pull_to_refresh_arrow",
                                      in: bundle,
                                      compatibleWith: nil)
        } else /* Manual */ {
            imageView.image = UIImage(named: "icon_pull_to_refresh_arrow")
        }
        return imageView
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor(white: 0.625, alpha: 1.0)
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.isHidden = true
        return indicatorView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(indicatorView)
    }
    
    // swiftlint:disable:next unavailable_function
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func refreshAnimationBegin(view: ESRefreshComponent) {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        imageView.isHidden = true
        imageView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat.pi)
    }
    
    open func refreshAnimationEnd(view: ESRefreshComponent) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        imageView.isHidden = false
        imageView.transform = CGAffineTransform.identity
    }
    
    open func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        // Do nothing
        
    }
    
    open func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        
        switch state {
        case .refreshing, .autoRefreshing:
            self.setNeedsLayout()
        case .releaseToRefresh:
            self.setNeedsLayout()
            self.impact()
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                options: UIView.AnimationOptions(),
                animations: { [weak self] in
                    self?.imageView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat.pi)
                })
        case .pullToRefresh:
            self.setNeedsLayout()
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                options: UIView.AnimationOptions(),
                animations: { [weak self] in
                    self?.imageView.transform = CGAffineTransform.identity
                })
        default:
            break
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let s = self.bounds.size
        let w = s.width
        let h = s.height
        
        UIView.performWithoutAnimation {
            indicatorView.center = CGPoint(x: w / 2.0, y: h / 2.0)
            imageView.frame = CGRect(x: titleLabel.frame.origin.x - 28.0,
                                     y: (h - 18.0) / 2.0,
                                     width: 18.0,
                                     height: 18.0)
        }
    }
    
}
