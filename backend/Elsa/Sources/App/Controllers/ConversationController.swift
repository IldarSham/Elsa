//
//  ConversationController.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.01.2025.
//

import Vapor
import Fluent

struct ConversationController: RouteCollection {
  
  static let eventsStreamGroupManager = EventsStreamGroupManager<ConversationEventDTO>()
  
  func boot(routes: RoutesBuilder) throws {
    let conversationsRoute = routes.grouped("api", "conversations")
    
    let tokenAuthMiddleware = Token.authenticator()
    let guardAuthMiddleware = User.guardMiddleware()
    
    let tokenAuthGroup = conversationsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    tokenAuthGroup.on(.GET, use: getAllHandler)
    tokenAuthGroup.on(.GET, ":conversation_id", "stream", use: streamUpdatesHandler)
    tokenAuthGroup.on(.POST, "create", use: createHandler)
  }
  
  @Sendable
  func getAllHandler(req: Request) async throws -> Page<ConversationDTO> {
    let user = try req.auth.require(User.self)
    
    let conversations = try await Conversation.query(on: req.db)
      .filter(\.$creator.$id == user.requireID())
      .sort(\.$createdAt, .descending)
      .paginate(for: req)
    
    return .init(
      items: try conversations.items.map { try $0.toDTO() },
      metadata: conversations.metadata
    )
  }
  
  @Sendable
  func streamUpdatesHandler(req: Request) async throws -> EventsStream<ConversationEventDTO> {
    let user = try req.auth.require(User.self)
    
    guard let conversationId = req.parameters.get("conversation_id", as: Conversation.IDValue.self) else {
      throw Abort(.badRequest)
    }
    
    let conversation = try await
      Conversation.fetch(by: conversationId, userId: user.requireID(), db: req.db)
    
    let manager = await Self.eventsStreamGroupManager.create(for: try conversation.requireID())
    return await manager.createEventsStream()
  }
  
  @Sendable
  func createHandler(req: Request) async throws -> ConversationDTO {
    let user = try req.auth.require(User.self)
    
    let conversation = try Conversation(creator: user)
    try await conversation.save(on: req.db)
    
    return try conversation.toDTO()
  }
}
