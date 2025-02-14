//
//  Conversation.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.01.2025.
//

import Foundation

struct Conversation: Decodable {
  let id: UUID
  let createdAt: Int
  var title: String?
}
