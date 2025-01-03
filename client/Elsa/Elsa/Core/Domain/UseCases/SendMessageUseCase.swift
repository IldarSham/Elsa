//
//  SendMessageUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol SendMessageUseCaseProtocol {
  
  @discardableResult
  func send(to conversationId: UUID, text: String) async throws -> Message
}

final class SendMessageUseCase: SendMessageUseCaseProtocol {
  
  private let remoteAPI: MessagesRemoteAPIProtocol
  
  init(remoteAPI: MessagesRemoteAPIProtocol) {
    self.remoteAPI = remoteAPI
  }
  
  @discardableResult
  func send(to conversationId: UUID, text: String) async throws -> Message {
    try await remoteAPI.sendMessage(to: conversationId,
                                    text: text)
  }
}
