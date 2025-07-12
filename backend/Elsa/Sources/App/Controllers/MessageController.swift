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
    
    await handleNewMessage(message, in: conversation, req: req)
    
    return try message.toDTO()
  }
  
  // MARK: — Private Helpers
  
  private func handleNewMessage(
    _ message: Message,
    in conversation: Conversation,
    req: Request
  ) async {
    do {
      try await broadcast(.newMessage(message), for: conversation.requireID())
      try await setTitleIfNeeded(
        for: conversation, newTitle: message.content, req: req)
      try await generateBotReply(for: message, req: req)
    } catch {
      req.logger.report(error: error)
    }
  }
  
  private func setTitleIfNeeded(
    for conversation: Conversation,
    newTitle: String,
    req: Request
  ) async throws {
    guard conversation.title == nil else { return }
    
    conversation.title = newTitle
    try await conversation.save(on: req.db)
    
    let updatedTitle = UpdatedTitle(
      conversation: conversation,
      updatedTitle: newTitle)
    try await broadcast(.updatedTitle(updatedTitle), for: conversation.requireID())
  }
  
  private func generateBotReply(for message: Message, req: Request) async throws {
    try await Task.sleep(for: .seconds(0.5))
    
    let replyText = await bot.getResponse(to: message.content)
    let replyMessage = try Message(
      sender: .assistant,
      content: replyText,
      conversation: message.conversation
    )
    
    try await replyMessage.save(on: req.db)
    try await replyMessage.$conversation.load(on: req.db)

    try await broadcast(.newMessage(replyMessage), for: replyMessage.conversation.requireID())
  }
  
  private func broadcast(_ event: ConversationEvent, for conversationId: Conversation.IDValue) async throws {
    try await ConversationController.sseHub.send(
      event.toDTO(),
      to: conversationId
    )
  }
}
