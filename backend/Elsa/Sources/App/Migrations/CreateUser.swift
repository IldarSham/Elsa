//
//  CreateUser.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 05.11.2024.
//

import Fluent

struct CreateUser: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("users")
      .field("id", .int, .identifier(auto: true))
      .field("first_name", .string, .required)
      .field("last_name", .string, .required)
      .field("email", .string, .required)
      .field("password_hash", .string, .required)
      .unique(on: "email")
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("users").delete()
  }
}
