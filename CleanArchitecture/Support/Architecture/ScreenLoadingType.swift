//
//  ScreenLoadingType.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/7/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

public enum ScreenLoadingType<Input> {
    case loading(Input)
    case reloading(Input)
}
