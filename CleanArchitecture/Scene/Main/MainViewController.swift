//
//  MainViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Reusable
import Then
import Combine

final class MainViewController: UIViewController, Bindable {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: MainViewModel!
    var cancelBag = CancelBag()
    
    private var output: MainViewModel.Output!
    private let selectMenuTrigger = PassthroughSubject<IndexPath, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    private func configView() {
        tableView.do {
            $0.rowHeight = 60
            $0.register(cellType: MenuCell.self)
            $0.delegate = self
            $0.dataSource = self
        }
        
        title = "Templates"
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input(
            loadTrigger: Driver.just(()),
            selectMenuTrigger: selectMenuTrigger.asDriver()
        )
        
        output = viewModel.transform(input, cancelBag: cancelBag)
    }

}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return output.menuSections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectMenuTrigger.send(indexPath)
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return output.menuSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.menuSections[section].menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = output.menuSections[indexPath.section].menus[indexPath.row]
        
        return tableView.dequeueReusableCell(for: indexPath, cellType: MenuCell.self).then {
            $0.titleLabel.text = menu.description
        }
    }
}

// MARK: - StoryboardSceneBased
extension MainViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
