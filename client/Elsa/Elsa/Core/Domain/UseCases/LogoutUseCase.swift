//
//  LogoutUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol LogoutUseCaseProtocol {
  func logout() throws
}

final class LogoutUseCase: LogoutUseCaseProtocol {
  
  private let dataStore: UserSessionDataStoreProtocol
  
  init(dataStore: UserSessionDataStoreProtocol) {
    self.dataStore = dataStore
  }
  
  func logout() throws {
    try dataStore.deleteUserSession()
  }
}
