//
//  LoginUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol LoginUseCaseProtocol {
  func login(email: String, password: String) async throws -> RemoteUserSession
}

final class LoginUseCase: LoginUseCaseProtocol {
  
  private let remoteAPI: AuthRemoteAPIProtocol
  private let dataStore: UserSessionDataStoreProtocol
  
  init(remoteAPI: AuthRemoteAPIProtocol, dataStore: UserSessionDataStoreProtocol) {
    self.remoteAPI = remoteAPI
    self.dataStore = dataStore
  }
  
  func login(email: String, password: String) async throws -> RemoteUserSession {
    let session = try await
      remoteAPI.login(email: email, password: password)
    try dataStore.save(userSession: session)
    return session
  }
}
