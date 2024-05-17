//
//  API+Repo.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/31/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Alamofire
import Combine

// MARK: - GetRepoList
extension API {
    func getRepoList(_ input: GetRepoListInput) -> AnyPublisher<GetRepoListOutput, Error> {
        return request(input)
    }
    
    final class GetRepoListInput: APIInput {
        init(page: Int, perPage: Int) {
            let params: Parameters = [
                "q": "language:swift",
                "per_page": perPage,
                "page": page
            ]
            
            super.init(urlString: API.Urls.getRepoList,
                       parameters: params,
                       method: .get,
                       requireAccessToken: true)
            
            usingCache = false
        }
    }
    
    final class GetRepoListOutput: Decodable {
        private(set) var repos: [Repo]?
        
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case repos = "items"
        }
    }
}
