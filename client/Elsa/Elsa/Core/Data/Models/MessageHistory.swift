//
//  MessageHistory.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 26.10.2025.
//

import Foundation

struct MessageHistory: Decodable {
  let messages: [Message]
  let hasMore: Bool
}
