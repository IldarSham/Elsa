//
//  Page.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 22.12.2024.
//

import Foundation

struct Page<T: Decodable>: Decodable {
    let items: [T]
    let metadata: PageMetadata
}

struct PageMetadata: Decodable {
    let page: Int
    let per: Int
    let total: Int
}
