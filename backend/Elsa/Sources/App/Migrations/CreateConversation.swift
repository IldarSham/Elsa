//
//  CreateConversation.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 09.12.2024.
//

import Fluent

struct CreateConversation: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("conversations")
      .id()
      .field("created_at", .datetime)
      .field("title", .string)
      .field("creator_id", .int, .references("users", "id", onDelete: .cascade))
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("conversations").delete()
  }
}
