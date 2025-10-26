//
//  File.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 26.10.2025.
//

import Vapor

struct MessageHistoryDTO: Content {
  let messages: [MessageDTO]
  let hasMore: Bool
}
