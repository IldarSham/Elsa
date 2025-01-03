//
//  Message.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 03.12.2024.
//

import Fluent
import Vapor

final class Message: Model, @unchecked Sendable {
  static let schema = "messages"
  
  @ID(custom: "id")
  var id: Int?
  
  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?
  
  @Field(key: "sender")
  var sender: MessageSender
  
  @Field(key: "content")
  var content: String
  
  @Parent(key: "conversation_id")
  var conversation: Conversation
  
  init() { }
  
  init(
    id: Int? = nil,
    createdAt: Date? = nil,
    sender: MessageSender,
    content: String,
    conversation: Conversation
  ) throws {
    self.id = id
    self.createdAt = createdAt
    self.sender = sender
    self.content = content
    self.$conversation.id = try conversation.requireID()
  }
  
  func toDTO() throws -> MessageDTO {
    .init(id: try self.requireID(),
          createdAt: createdAt != nil ? Int(createdAt!.timeIntervalSince1970) : nil,
          conversationId: try conversation.requireID(),
          sender: sender,
          content: content)
  }
}
