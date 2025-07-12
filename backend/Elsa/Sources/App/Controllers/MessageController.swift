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
  
  func boot(routes: RoutesBuilder) throws {
    let messagesRoute = routes.grouped("api", "messages")
    
    let tokenAuthMiddleware = Token.authenticator()
    let guardAuthMiddleware = User.guardMiddleware()
    let tokenAuthGroup = messagesRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    tokenAuthGroup.on(.GET, use: getAllHandler)
    tokenAuthGroup.on(.POST, "send", use: sendHandler)
  }
  
  @Sendable
  func getAllHandler(req: Request) async throws -> Page<MessageDTO> {
    let user = try req.auth.require(User.self)

    guard let conversationId: Conversation.IDValue = req.query["conversation_id"] else {
      throw Abort(.badRequest)
    }
    
    let conversation = try await
      Conversation.fetch(by: conversationId, userId: user.requireID(), db: req.db)
    
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
  func sendHandler(req: Request) async throws -> MessageDTO {
    let user = try req.auth.require(User.self)
    let sendData = try req.content.decode(MessageSendRequest.self)
    
    let conversation = try await Conversation.fetch(
      by: sendData.conversationId,
      userId: user.requireID(),
      db: req.db
    )
    
    let message = try Message(
      sender: .user,
      content: sendData.content,
      conversation: conversation
    )
    try await message.save(on: req.db)
    try await message.$conversation.load(on: req.db)
    
    try await processNewMessage(message, req: req)
    try await setTitleIfNeeded(for: conversation, newTitle: sendData.content, req: req)
    
    return try message.toDTO()
  }
  
  
  private func setTitleIfNeeded(for conversation: Conversation,
                                newTitle: String,
                                req: Request) async throws {
    guard conversation.title == nil else { return }
    
    conversation.title = newTitle
    try await conversation.save(on: req.db)
    
    let updatedTitle = UpdatedTitle(conversation: conversation, updatedTitle: newTitle)
    let event = ConversationEvent(updatedTitle: updatedTitle)
    try await broadcastEvent(event, for: conversation.requireID())
  }
  
  private func processNewMessage(_ message: Message, req: Request) async throws {
    let event = ConversationEvent(newMessage: message)
    try await broadcastEvent(event, for: message.conversation.requireID())
    try await generateAssistantResponse(for: message, req: req)
  }
  
  private func generateAssistantResponse(for message: Message, req: Request) async throws {
    try await Task.sleep(for: .seconds(0.5))
    
    let responseText = await bot.getResponse(to: message.content)
    let assistantMessage = try Message(
      sender: .assistant,
      content: responseText,
      conversation: message.conversation
    )
    try await assistantMessage.save(on: req.db)
    try await assistantMessage.$conversation.load(on: req.db)
    
    let event = ConversationEvent(newMessage: assistantMessage)
    try await broadcastEvent(event, for: assistantMessage.conversation.requireID())
  }
  
  private func broadcastEvent(_ event: ConversationEvent,
                              for conversationId: Conversation.IDValue) async throws {
    try await ConversationController.sseHub.send(event.toDTO(), to: conversationId)
  }
}
