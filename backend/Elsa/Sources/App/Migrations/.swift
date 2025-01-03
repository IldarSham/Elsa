//
//  CreateTodo 2.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 05.11.2024.
//


struct CreateTodo: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("todos")
            .id()
            .field("title", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("todos").delete()
    }
}
