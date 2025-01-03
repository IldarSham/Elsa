//
//  StreamMessageEventsUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol StreamMessageEventsUseCaseProtocol {
  func stream(for conversationId: UUID) async throws -> AsyncStream<MessageEvent>
}

final class StreamMessageEventsUseCase: StreamMessageEventsUseCaseProtocol {
  
  private let remoteAPI: MessagesRemoteAPIProtocol
  
  init(remoteAPI: MessagesRemoteAPIProtocol) {
    self.remoteAPI = remoteAPI
  }
  
  func stream(for conversationId: UUID) async throws -> AsyncStream<MessageEvent> {
    return try await remoteAPI.streamMessageEvents(for: conversationId)
  }
}
