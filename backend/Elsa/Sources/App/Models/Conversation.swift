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
  
  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?
  
  @OptionalField(key: "title")
  var title: String?
  
  @Children(for: \.$conversation)
  var messages: [Message]
  
  @Parent(key: "creator_id")
  var creator: User
  
  init() { }
  
  init(
    id: UUID? = nil,
    createdAt: Date? = nil,
    title: String? = nil,
    creator: User
  ) throws {
    self.id = id
    self.createdAt = createdAt
    self.title = title
    self.$creator.id = try creator.requireID()
  }
  
  func toDTO() throws -> ConversationDTO {
    .init(id: try requireID(),
          createdAt: createdAt != nil ? Int(createdAt!.timeIntervalSince1970) : nil,
          title: title)
  }
}

extension Conversation {
  
  static func fetch(by id: Conversation.IDValue, userId: User.IDValue, db: Database) async throws -> Conversation {
    guard let conversation = try await Conversation.query(on: db)
      .filter(\.$id == id)
      .filter(\.$creator.$id == userId)
      .first() else {
      throw Abort(.forbidden, reason: "You do not have access to this conversation")
    }
    return conversation
  }
}
