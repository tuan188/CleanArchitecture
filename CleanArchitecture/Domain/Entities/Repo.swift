//
//  Repo.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/31/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Then

struct Repo {
    var id: Int?
    var name: String?
    var fullname: String?
    var urlString: String?
    var starCount: Int?
    var folkCount: Int?
    var owner: Owner?
    
    struct Owner: Decodable {
        var avatarUrl: String?
        
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case avatarUrl = "avatar_url"
        }
    }
}

extension Repo: Then, Equatable {
    static func == (lhs: Repo, rhs: Repo) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Repo: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, name
        case fullname = "full_name"
        case urlString = "html_url"
        case starCount = "stargazers_count"
        case folkCount = "forks"
        case owner
    }
}
