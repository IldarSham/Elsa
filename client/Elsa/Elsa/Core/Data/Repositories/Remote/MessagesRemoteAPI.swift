//
//  MessagesRemoteAPI.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 22.12.2024.
//

import Foundation

protocol MessagesRemoteAPIProtocol {
  func getMessageHistory(for conversationId: UUID, count: Int, beforeMessageId: Int?) async throws -> MessageHistory
  func sendMessage(to conversationId: UUID, text: String) async throws -> Message
}

final class MessagesRemoteAPI: MessagesRemoteAPIProtocol {
  
  private let userSession: RemoteUserSession
  private let apiManager: RemoteAPIManagerProtocol
  
  init(userSession: RemoteUserSession, apiManager: RemoteAPIManagerProtocol) {
    self.userSession = userSession
    self.apiManager = apiManager
  }
  
  func getMessageHistory(for conversationId: UUID, count: Int, beforeMessageId: Int?) async throws -> MessageHistory {
    let request = MessageHistoryRequest(
      conversationId: conversationId,
      count: count,
      beforeMessageId: beforeMessageId
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
}
