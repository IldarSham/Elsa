//
//  StreamConversationEventsUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol StreamConversationEventsUseCaseProtocol {
  func stream(for conversationId: UUID) async throws -> AsyncStream<ConversationEvent>
}

final class StreamConversationEventsUseCase: StreamConversationEventsUseCaseProtocol {
  
  private let remoteAPI: ConversationsRemoteAPIProtocol
  
  init(remoteAPI: ConversationsRemoteAPIProtocol) {
    self.remoteAPI = remoteAPI
  }
  
  func stream(for conversationId: UUID) async throws -> AsyncStream<ConversationEvent> {
    return try await remoteAPI.streamEvents(for: conversationId)
  }
}
