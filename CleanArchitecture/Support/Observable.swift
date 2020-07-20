//
//  Observable.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/16/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import Combine

public typealias Observable<T> = AnyPublisher<T, Error>
