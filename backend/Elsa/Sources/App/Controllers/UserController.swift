//
//  UserController.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 05.11.2024.
//

import Vapor

struct UserSession: Content {
  let token: String
  let user: UserDTO
  let initialConversationId: Conversation.IDValue
}

struct UserController: RouteCollection {
  
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("api", "users")
    usersRoute.post("register", use: self.registerHandler)
    
    let basicAuthGroup = usersRoute.grouped(User.authenticator())
    basicAuthGroup.post("login", use: self.loginHandler)
  }
  
  @Sendable
  func registerHandler(req: Request) async throws -> UserSession {
    let registerData = try req.content.decode(RegisterUserRequest.self)
    
    let user = try User.create(from: registerData)
    try await user.save(on: req.db)
    
    let token = try Token.generate(for: user)
    try await token.save(on: req.db)
    
    let conversation = try Conversation(creator: user)
    try await conversation.save(on: req.db)
    
    return UserSession(
      token: token.value,
      user: try user.toDTO(),
      initialConversationId: try conversation.requireID())
  }
  
  @Sendable
  func loginHandler(req: Request) async throws -> UserSession {
    let user = try req.auth.require(User.self)
    
    let token = try Token.generate(for: user)
    try await token.save(on: req.db)
    
    guard let conversation = try await user.$conversations.query(on: req.db).first() else {
      throw Abort(.notFound, reason: "Conversation not found for the user")
    }
    
    return UserSession(
      token: token.value,
      user: try user.toDTO(),
      initialConversationId: try conversation.requireID())
  }
}
