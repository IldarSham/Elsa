//
//  ConversationsRemoteAPI.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.01.2025.
//

import Foundation

protocol ConversationsRemoteAPIProtocol {
  func getAllConversations(page: Int, per: Int) async throws -> Page<Conversation>
  func createConversation() async throws -> Conversation
  func streamEvents(for conversationId: UUID) async throws -> AsyncStream<ConversationEvent>
}

final class ConversationsRemoteAPI: ConversationsRemoteAPIProtocol {
  
  private let userSession: RemoteUserSession
  private let apiManager: RemoteAPIManagerProtocol
  
  init(userSession: RemoteUserSession, apiManager: RemoteAPIManagerProtocol) {
    self.userSession = userSession
    self.apiManager = apiManager
  }
  
  func getAllConversations(page: Int, per: Int) async throws -> Page<Conversation> {
    let request = ConversationsListRequest(
      page: page,
      per: per
    )
    return try await apiManager.callAPI(with: request, authToken: userSession.token)
  }
  
  func createConversation() async throws -> Conversation {
    let request = CreateConversationRequest()
    return try await apiManager.callAPI(with: request, authToken: userSession.token)
  }
  
  func streamEvents(for conversationId: UUID) async throws -> AsyncStream<ConversationEvent> {
    let request = StreamConversationEventsLiveRequest(conversationId: conversationId)
    return try await apiManager.callAPI(with: request, authToken: userSession.token)
  }
}
