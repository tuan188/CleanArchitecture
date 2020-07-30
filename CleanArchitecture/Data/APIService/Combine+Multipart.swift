//
//  Combine+Multipart.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/30/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Alamofire
import Combine

//extension Reactive where Base: SessionManager {
//    func upload(to url: URLConvertible,
//                method: HTTPMethod = .post,
//                headers: HTTPHeaders = [:],
//                data: @escaping (MultipartFormData) -> Void) -> Observable<UploadRequest> {
//        return Observable.create { observer in
//            self.base.upload(multipartFormData: data,
//                             to: url,
//                             method: method,
//                             headers: headers,
//                             encodingCompletion: { (result: SessionManager.MultipartFormDataEncodingResult) in
//                                switch result {
//                                case .failure(let error):
//                                    observer.onError(error)
//                                case .success(let request, _, _):
//                                    observer.onNext(request)
//                                    observer.onCompleted()
//                                }
//            })
//            
//            return Disposables.create()
//        }
//    }
//}
