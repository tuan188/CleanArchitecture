//
//  MainViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Combine

class MainViewModel: ShowProductList, // swiftlint:disable:this final_class
                     ShowLogin,
                     ShowRepoList,
                     ShowRepoCollection {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func vm_showProductList() {
        showProductList()
    }
    
    func vm_showLogin() {
        showLogin()
    }
    
    func vm_showRepoList() {
        showRepoList()
    }
    
    func vm_showRepoCollection() {
        showRepoCollection()
    }
}

// MARK: - ViewModelType
extension MainViewModel: ObservableObject, ViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
        let selectMenuTrigger: AnyPublisher<IndexPath, Never>
    }
    
    final class Output: ObservableObject {
        @Published var menuSections: [MenuSection] = []
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        
        input.loadTrigger
            .map {
                self.menuSections()
            }
            .assign(to: \.menuSections, on: output)
            .store(in: cancelBag)
        
        input.selectMenuTrigger
            .handleEvents(receiveOutput: { [unowned self] indexPath in
                let menu = output.menuSections[indexPath.section].menus[indexPath.row]
                switch menu {
                case .products:
                    self.vm_showProductList()
//                case .sectionedProducts:
//                    self.navigator.toSectionedProducts()
                case .repos:
                    self.vm_showRepoList()
                case .repoCollection:
                    self.vm_showRepoCollection()
//                case .users:
//                    self.navigator.toUsers()
                case .login:
                    self.vm_showLogin()
                }
            })
            .sink()
            .store(in: cancelBag)
                
        return output
    }
    
    private func menuSections() -> [MenuSection] {
        return [
            MenuSection(title: "Mock Data", menus: [.products ]),
            MenuSection(title: "API", menus: [.repos, .repoCollection]),
//            MenuSection(title: "Core Data", menus: [ .users ]),
            MenuSection(title: "", menus: [ .login ])
        ]
    }
}

extension MainViewModel {
    enum Menu: Int, CustomStringConvertible, CaseIterable {
        case products = 0
//        case sectionedProducts = 1
        case repos = 2
        case repoCollection = 3
//        case users = 4
        case login = 5
        
        var description: String {
            switch self {
            case .products:
                return "Product list"
//            case .sectionedProducts:
//                return "Sectioned product list"
            case .repos:
                return "Git repo list"
            case .repoCollection:
                return "Git repo collection"
//            case .users:
//                return "User list"
            case .login:
                return "Login"
            }
        }
    }
    
    struct MenuSection {
        let title: String
        let menus: [Menu]
    }
}

