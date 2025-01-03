//
//  SignedInViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 19.12.2024.
//

import Foundation

final class SignedInViewModel {
  
  // MARK: - Properties
  private let userSession: RemoteUserSession
  
  public var initialConversationId: UUID {
    userSession.initialConversationId
  }
  
  // MARK: - Initialization
  init(userSession: RemoteUserSession) {
    self.userSession = userSession
  }
}
