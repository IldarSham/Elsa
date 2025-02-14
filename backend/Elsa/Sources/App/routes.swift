import Fluent
import Vapor

func routes(_ app: Application) throws {
  try app.register(collection: UserController())
  try app.register(collection: ConversationController())
  try app.register(collection: MessageController())
}
