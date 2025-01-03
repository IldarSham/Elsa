//
//  LoadMessagesListUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol LoadMessagesListUseCaseProtocol {
  func load(for conversationId: UUID, page: Int, per: Int) async throws -> Page<Message>
}

final class LoadMessagesListUseCase: LoadMessagesListUseCaseProtocol {
  
  private let remoteAPI: MessagesRemoteAPIProtocol
  
  init(remoteAPI: MessagesRemoteAPIProtocol) {
    self.remoteAPI = remoteAPI
  }
  
  func load(for conversationId: UUID, page: Int, per: Int) async throws -> Page<Message> {
    return try await remoteAPI.getAllMessages(for: conversationId,
                                              page: page,
                                              per: per)
  }
}
