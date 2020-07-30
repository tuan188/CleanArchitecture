//
//  Repo.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/31/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import ObjectMapper
import Then

struct Repo {
    var id = 0
    var name = ""
    var fullname = ""
    var urlString = ""
    var starCount = 0
    var folkCount = 0
    var avatarURLString = ""
}

extension Repo: Then, Equatable { }

extension Repo: Mappable {
    
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        fullname <- map["full_name"]
        urlString <- map["html_url"]
        starCount <- map["stargazers_count"]
        folkCount <- map["forks"]
        avatarURLString <- map["owner.avatar_url"]
    }
}
