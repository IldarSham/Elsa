//
//  LoadMessageHistoryUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol LoadMessageHistoryUseCaseProtocol {
  func load(for conversationId: UUID, count: Int, beforeMessageId: Int?) async throws -> MessageHistory
}

final class LoadMessagesListUseCase: LoadMessageHistoryUseCaseProtocol {
  
  private let remoteAPI: MessagesRemoteAPIProtocol
  
  init(remoteAPI: MessagesRemoteAPIProtocol) {
    self.remoteAPI = remoteAPI
  }
  
  func load(for conversationId: UUID, count: Int, beforeMessageId: Int?) async throws -> MessageHistory {
    return try await remoteAPI.getMessageHistory(
      for: conversationId,
      count: count,
      beforeMessageId: beforeMessageId
    )
  }
}
