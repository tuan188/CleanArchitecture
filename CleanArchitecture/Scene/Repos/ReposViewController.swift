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
            $0.refreshHeader = RefreshAutoHeader()
        }
    }
    
    func bindViewModel() {
        let input = ReposViewModel.Input(
            loadTrigger: Driver.just(()),
            reloadTrigger: tableView.refreshTrigger,
            loadMoreTrigger: tableView.loadMoreTrigger,
            selectRepoTrigger: selectRepoTrigger.asDriver()
        )
        
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        output.$repos
            .sink(receiveValue: { [unowned self] repos in
                self.repos = repos
                self.tableView.reloadData()
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

// MARK: - Subscribers
extension ReposViewController {
    
}

// MARK: - StoryboardSceneBased
extension ReposViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.repo
}
