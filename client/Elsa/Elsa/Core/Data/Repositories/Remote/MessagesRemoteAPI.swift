//
//  MessagesRemoteAPI.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 22.12.2024.
//

import Foundation

protocol MessagesRemoteAPIProtocol {
  func getAllMessages(for conversationId: UUID, page: Int, per: Int) async throws -> Page<Message>
  func sendMessage(to conversationId: UUID, text: String) async throws -> Message
  func streamMessageEvents(for conversationId: UUID) async throws -> AsyncStream<MessageEvent>
}

final class MessagesRemoteAPI: MessagesRemoteAPIProtocol {
  
  private let userSession: RemoteUserSession
  private let apiManager: RemoteAPIManagerProtocol
  
  init(userSession: RemoteUserSession, apiManager: RemoteAPIManagerProtocol) {
    self.userSession = userSession
    self.apiManager = apiManager
  }
  
  func getAllMessages(for conversationId: UUID, page: Int, per: Int) async throws -> Page<Message> {
    let request = MessagesListRequest(
      conversationId: conversationId,
      page: page,
      per: per
    )
    return try await apiManager.callAPI(with: request, authToken: userSession.token)
  }
  
  func sendMessage(to conversationId: UUID, text: String) async throws -> Message {
    let request = SendMessageRequest(
      conversationId: conversationId,
      content: text
    )
    return try await apiManager.callAPI(with: request, authToken: userSession.token)
  }
  
  func streamMessageEvents(for conversationId: UUID) async throws -> AsyncStream<MessageEvent> {
    let request = StreamMessageEventsLiveRequest(conversationId: conversationId)
    return try await apiManager.callAPI(with: request, authToken: userSession.token)
  }
}
