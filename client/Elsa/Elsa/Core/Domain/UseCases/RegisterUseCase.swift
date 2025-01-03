//
//  RegisterUseCase.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 31.12.2024.
//

import Foundation

protocol RegisterUseCaseProtocol {
  func register(newAccount: NewAccountPayload) async throws -> RemoteUserSession
}

final class RegisterUseCase: RegisterUseCaseProtocol {
  
  private let remoteAPI: AuthRemoteAPIProtocol
  private let dataStore: UserSessionDataStoreProtocol
  
  init(remoteAPI: AuthRemoteAPIProtocol, dataStore: UserSessionDataStoreProtocol) {
    self.remoteAPI = remoteAPI
    self.dataStore = dataStore
  }
  
  func register(newAccount: NewAccountPayload) async throws -> RemoteUserSession {
    let session = try await
      remoteAPI.register(newAccount: newAccount)
    try dataStore.save(userSession: session)
    return session
  }
}
