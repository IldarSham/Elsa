//
//  CreateConversationUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.01.2025.
//

import Foundation

protocol CreateConversationUseCaseProtocol {
  func create() async throws -> Conversation
}

final class CreateConversationUseCase: CreateConversationUseCaseProtocol {
  
  private let remoteAPI: ConversationsRemoteAPIProtocol
  
  init(remoteAPI: ConversationsRemoteAPIProtocol) {
    self.remoteAPI = remoteAPI
  }
  
  func create() async throws -> Conversation {
    return try await remoteAPI.createConversation()
  }
}
