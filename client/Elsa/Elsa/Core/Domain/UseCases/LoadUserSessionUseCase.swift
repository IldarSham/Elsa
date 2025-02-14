//
//  LoadUserSessionUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol LoadUserSessionUseCaseProtocol {
  func load() throws -> RemoteUserSession?
}

final class LoadUserSessionUseCase: LoadUserSessionUseCaseProtocol {
  
  private let dataStore: UserSessionDataStoreProtocol
  
  init(dataStore: UserSessionDataStoreProtocol) {
    self.dataStore = dataStore
  }
  
  func load() throws -> RemoteUserSession? {
    return try dataStore.readUserSession()
  }
}
