//
//  LoadConversationsListUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 29.01.2025.
//

import Foundation

protocol LoadConversationsListUseCaseProtocol {
  func load(page: Int, per: Int) async throws -> Page<Conversation>
}

final class LoadConversationsListUseCase: LoadConversationsListUseCaseProtocol {
  
  private let remoteAPI: ConversationsRemoteAPIProtocol
  
  init(remoteAPI: ConversationsRemoteAPIProtocol) {
    self.remoteAPI = remoteAPI
  }
  
  func load(page: Int, per: Int) async throws -> Page<Conversation> {
    return try await remoteAPI.getAllConversations(
      page: page,
      per: per
    )
  }
}
