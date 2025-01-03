import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  
  encoder.keyEncodingStrategy = .convertToSnakeCase
  decoder.keyDecodingStrategy = .convertFromSnakeCase

  ContentConfiguration.global.use(encoder: encoder, for: .json)
  ContentConfiguration.global.use(decoder: decoder, for: .json)
  
  app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
  
  app.migrations.add(CreateUser())
  app.migrations.add(CreateToken())
  app.migrations.add(CreateConversation())
  app.migrations.add(CreateMessage())
  
  try await app.autoMigrate()
  
  try routes(app)
}
