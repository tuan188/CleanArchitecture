//
//  ReposViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Reusable
import Combine
import SDWebImage
import Factory

final class ReposViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: PagingTableView!
    
    // MARK: - Properties
    
    var viewModel: ReposViewModel!
    var cancelBag = CancelBag()
    
    private var repos = [RepoItemViewModel]()
    private let selectRepoTrigger = PassthroughSubject<IndexPath, Never>()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: - Methods
    
    private func configView() {
        title = "Repo List"
        
        tableView.do {
            $0.register(cellType: RepoCell.self)
            $0.delegate = self
            $0.dataSource = self
            $0.prefetchDataSource = self
        }
    }
    
    func bindViewModel() {
        let input = ReposViewModel.Input(
            loadTrigger: Just(()).asDriver(),
            reloadTrigger: tableView.refreshTrigger.print().asDriver(),
            loadMoreTrigger: tableView.loadMoreTrigger,
            selectRepoTrigger: selectRepoTrigger.asDriver()
        )
        
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        output.$repos
            .sink(with: self, receiveValue: { vc, repos in
                vc.repos = repos
                vc.tableView.reloadData()
            })
            .store(in: cancelBag)
        
        output.$alert.subscribe(alertSubscriber)
        output.$isLoading.subscribe(loadingSubscriber)
        output.$isReloading.subscribe(tableView.isRefreshing)
        output.$isLoadingMore.subscribe(tableView.isLoadingMore)
    }
}

// MARK: - UITableViewDelegate
extension ReposViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectRepoTrigger.send(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}

// MARK: - UITableViewDataSource
extension ReposViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(for: indexPath, cellType: RepoCell.self).then {
            $0.bindViewModel(repos[indexPath.row])
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension ReposViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths
            .compactMap { repos[$0.row].url }
        
        print("Preheat", urls)
        SDWebImagePrefetcher.shared.prefetchURLs(urls)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
    }
}

// MARK: - Subscribers
extension ReposViewController {
    
}

// MARK: - StoryboardSceneBased
extension ReposViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.repo
}

// MARK: - Factory
extension Container {
    func reposViewController(navigationController: UINavigationController) -> Factory<ReposViewController> {
        Factory(self) {
            let vc = ReposViewController.instantiate()
            let vm = ReposViewModel()
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
