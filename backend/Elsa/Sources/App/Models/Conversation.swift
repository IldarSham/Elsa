//
//  Conversation.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 09.12.2024.
//

import Fluent
import Vapor

final class Conversation: Model, @unchecked Sendable {
  static let schema = "conversations"
  
  @ID
  var id: UUID?
  
  @Children(for: \.$conversation)
  var messages: [Message]
  
  @Parent(key: "creator_id")
  var creator: User
  
  init() { }
  
  init(id: UUID? = nil, creator: User) throws {
    self.id = id
    self.$creator.id = try creator.requireID()
  }
}
