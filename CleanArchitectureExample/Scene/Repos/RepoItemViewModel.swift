//
//  RepoItemViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/3/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Foundation

struct RepoItemViewModel {
    let repo: Repo
    let name: String
    let url: URL?
    
    init(repo: Repo) {
        self.repo = repo
        name = repo.name ?? ""
        url = URL(string: repo.owner?.avatarUrl ?? "")
    }
}
