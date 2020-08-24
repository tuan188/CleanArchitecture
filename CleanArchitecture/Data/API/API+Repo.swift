//
//  API+Repo.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/31/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import ObjectMapper
import Alamofire

// MARK: - GetRepoList
extension API {
    func getRepoList(_ input: GetRepoListInput) -> Observable<GetRepoListOutput> {
        return request(input)
    }
    
    final class GetRepoListInput: APIInput {
        init(dto: GetReposDto) {
            let params: Parameters = [
                "q": "language:swift",
                "per_page": dto.perPage,
                "page": dto.page
            ]
            
            super.init(urlString: API.Urls.getRepoList,
                       parameters: params,
                       method: .get,
                       requireAccessToken: true)
            
            usingCache = dto.usingCache
        }
    }
    
    final class GetRepoListOutput: APIOutput {
        private(set) var repos: [Repo]?
        
        override func mapping(map: Map) {
            super.mapping(map: map)
            repos <- map["items"]
        }
    }
}
