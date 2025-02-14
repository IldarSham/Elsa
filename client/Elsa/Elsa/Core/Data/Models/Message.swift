//
//  Message.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 18.12.2024.
//

import Foundation

struct Message: Decodable, Equatable, Identifiable {
  let id: Int
  let createdAt: Int
  let conversationId: UUID
  let sender: MessageSender
  let content: String
  
  static func == (lhs: Message, rhs: Message) -> Bool {
    lhs.id == rhs.id
  }
}
