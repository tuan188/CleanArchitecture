//
//  Assembler.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/14/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

protocol Assembler: class,
    ProductDetailAssembler,
    ProductsAssembler,
    MainAssembler,
    LoginAssembler,
    GatewaysAssembler,
    AppAssembler {
    
}

final class DefaultAssembler: Assembler {
    
}

final class PreviewAssembler: Assembler {
    
}
