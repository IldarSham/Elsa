//
//  CreateMessage.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 03.12.2024.
//

import Fluent

struct CreateMessage: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("messages")
      .field("id", .int, .identifier(auto: true))
      .field("created_at", .datetime)
      .field("sender", .string, .required)
      .field("content", .string, .required)
      .field("conversation_id", .uuid, .references("conversations", "id", onDelete: .cascade))
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("messages").delete()
  }
}
