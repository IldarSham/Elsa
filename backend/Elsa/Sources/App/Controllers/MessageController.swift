//
//  MessageController.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 03.12.2024.
//

import Vapor
import Fluent

struct MessageController: RouteCollection, Sendable {
  
  private let bot = Bot()
  private let eventsStreamGroup = EventsStreamGroup<MessageEventDTO>()
  
  func boot(routes: RoutesBuilder) throws {
    let messagesRoute = routes.grouped("api", "messages")
    
    let tokenAuthMiddleware = Token.authenticator()
    let guardAuthMiddleware = User.guardMiddleware()
    
    let tokenAuthGroup = messagesRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    tokenAuthGroup.on(.GET, use: getAllHandler)
    tokenAuthGroup.on(.GET, "stream", use: streamingHandler)
    tokenAuthGroup.on(.POST, "send", use: sendHandler)
  }
  
  @Sendable
  func getAllHandler(req: Request) async throws -> Page<MessageDTO> {
    let user = try req.auth.require(User.self)

    guard let conversationId: Conversation.IDValue = req.query["conversation_id"] else {
      throw Abort(.badRequest)
    }
    
    let conversation = try await
      fetchConversation(by: conversationId, userId: user.requireID(), db: req.db)
    
    let messages = try await Message.query(on: req.db)
      .filter(\.$conversation.$id == conversation.requireID())
      .sort(\.$id, .descending)
      .with(\.$conversation)
      .paginate(for: req)
    
    return .init(
      items: try messages.items.reversed().map { try $0.toDTO() },
      metadata: messages.metadata
    )
  }
  
  @Sendable
  func streamingHandler(req: Request) async throws -> EventsStream<MessageEventDTO> {
    let user = try req.auth.require(User.self)

    guard let conversationId: Conversation.IDValue = req.query["conversation_id"] else {
      throw Abort(.badRequest)
    }
    
    let conversation = try await
      fetchConversation(by: conversationId, userId: user.requireID(), db: req.db)
    
    let manager = await eventsStreamGroup.create(for: try conversation.requireID())
    return await manager.createEventsStream()
  }
  
  @Sendable
  func sendHandler(req: Request) async throws -> MessageDTO {
    let user = try req.auth.require(User.self)
    
    let sendData = try req.content.decode(MessageSendRequest.self)
    
    let conversation = try await
      fetchConversation(by: sendData.conversationId, userId: user.requireID(), db: req.db)
    
    let message = try Message(
      sender: .user,
      content: sendData.content,
      conversation: conversation)
    try await message.save(on: req.db)
    
    try await message.$conversation.load(on: req.db)
    
    Task {
      do {
        try await handleIncomingMessage(message, req: req)
      } catch {
        req.logger.report(error: error)
      }
    }
    
    return try message.toDTO()
  }
  
  private func handleIncomingMessage(_ message: Message, req: Request) async throws {
    try await
      broadcastEvent(MessageEvent(newMessage: message), for: message.conversation.id!)
    try await generateAssistantResponse(for: message, req: req)
  }
  
  private func generateAssistantResponse(for message: Message, req: Request) async throws {
    let responseText = await bot.getResponse(to: message.content)
    
    let assistantMessage = try Message(
      sender: .assistant,
      content: responseText,
      conversation: message.conversation)
    try await assistantMessage.save(on: req.db)
  
    try await assistantMessage.$conversation.load(on: req.db)
    
    try await
      broadcastEvent(MessageEvent(newMessage: assistantMessage), for: assistantMessage.conversation.id!)
  }
  
  private func broadcastEvent(_ event: MessageEvent, for conversationId: Conversation.IDValue) async throws {
    let manager = await eventsStreamGroup.get(for: conversationId)
    try await manager?.send(event.toDTO())
  }
  
  private func fetchConversation(by id: Conversation.IDValue, userId: User.IDValue, db: Database) async throws -> Conversation {
    guard let conversation = try await Conversation.query(on: db)
      .filter(\.$id == id)
      .filter(\.$creator.$id == userId)
      .first() else {
      throw Abort(.forbidden, reason: "You do not have access to this conversation")
    }
    return conversation
  }
}
