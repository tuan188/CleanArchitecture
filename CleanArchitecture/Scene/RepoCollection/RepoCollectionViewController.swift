//
//  RepoCollectionViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/5/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import ESPullToRefresh
import SDWebImage
import Combine
import Reusable

final class RepoCollectionViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: PagingCollectionView!
    
    // MARK: - Properties
    
    var viewModel: ReposViewModel!
    var cancelBag = CancelBag()
    
    private var repos = [RepoItemViewModel]()
    private let selectRepoTrigger = PassthroughSubject<IndexPath, Never>()
    
    struct LayoutOptions {
        var itemSpacing: CGFloat = 16
        var lineSpacing: CGFloat = 16
        var itemsPerRow: Int = 2
        
        var sectionInsets = UIEdgeInsets(
            top: 16.0,
            left: 16.0,
            bottom: 16.0,
            right: 16.0
        )
        
        var itemSize: CGSize {
            let screenSize = UIScreen.main.bounds
            
            let paddingSpace = sectionInsets.left
                + sectionInsets.right
                + CGFloat(itemsPerRow - 1) * itemSpacing
            
            let availableWidth = screenSize.width - paddingSpace
            let widthPerItem = availableWidth / CGFloat(itemsPerRow)
            let heightPerItem = widthPerItem
            
            return CGSize(width: widthPerItem, height: heightPerItem)
        }
    }
    
    private var layoutOptions = LayoutOptions()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.refreshHeader = RefreshHeaderAnimator(frame: .zero)
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: - Methods
    
    private func configView() {
        collectionView.do {
            $0.register(cellType: RepoCollectionCell.self)
            $0.alwaysBounceVertical = true
            $0.prefetchDataSource = self
            $0.dataSource = self
            $0.delegate = self
//            $0.refreshHeader = RefreshAutoHeader(frame: .zero)
            // need to set the Estimate Size to None in the collection view size panel.
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
        collectionView.backgroundColor = ColorCompatibility.systemBackground
    }
    
    func bindViewModel() {
        let input = ReposViewModel.Input(
            loadTrigger: Driver.just(()),
            reloadTrigger: collectionView.refreshTrigger,
            loadMoreTrigger: collectionView.loadMoreTrigger,
            selectRepoTrigger: selectRepoTrigger.asDriver()
        )
        
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        output.$repos
            .sink(receiveValue: { [unowned self] repos in
                self.repos = repos
                self.collectionView.reloadData()
            })
            .store(in: cancelBag)
        
        output.$alert.subscribe(alertSubscriber)
        output.$isLoading.subscribe(loadingSubscriber)
        output.$isReloading.subscribe(collectionView.isRefreshing)
        output.$isLoadingMore.subscribe(collectionView.isLoadingMore)
    }
}

// MARK: - StoryboardSceneBased
extension RepoCollectionViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.repo
}

// MARK: - UICollectionViewDataSource
extension RepoCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        repos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(for: indexPath, cellType: RepoCollectionCell.self).then {
            $0.bindViewModel(repos[indexPath.row])
        }
    }
}

// MARK: - UICollectionViewDelegate
extension RepoCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layoutOptions.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return layoutOptions.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return layoutOptions.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return layoutOptions.itemSpacing
    }
    
}

// MARK: - UICollectionViewDataSourcePrefetching
extension RepoCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths
            .compactMap { repos[$0.row].url }
        
        print("Preheat", urls)
        SDWebImagePrefetcher.shared.prefetchURLs(urls)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
}
