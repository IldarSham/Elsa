//
//  AuthRemoteAPI.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 19.12.2024.
//

import Foundation

protocol AuthRemoteAPIProtocol {
  func login(email: String, password: String) async throws -> RemoteUserSession
  func register(newAccount: NewAccountPayload) async throws -> RemoteUserSession
}

final class AuthRemoteAPI: AuthRemoteAPIProtocol {
  
  private let apiManager: RemoteAPIManagerProtocol
  
  init(apiManager: RemoteAPIManagerProtocol) {
    self.apiManager = apiManager
  }
  
  func login(email: String, password: String) async throws -> RemoteUserSession {
    let request = LoginRequest(
      email: email,
      password: password
    )
    return try await apiManager.callAPI(with: request)
  }
  
  func register(newAccount: NewAccountPayload) async throws -> RemoteUserSession {
    let request = RegisterRequest(
      firstName: newAccount.firstName,
      lastName: newAccount.lastName,
      email: newAccount.email,
      password: newAccount.password
    )
    return try await apiManager.callAPI(with: request)
  }
}
