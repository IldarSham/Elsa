//
//  UserSessionDataStore.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 19.12.2024.
//

import Foundation

protocol UserSessionDataStoreProtocol {
  func readUserSession() throws -> RemoteUserSession?
  func save(userSession: RemoteUserSession) throws
  func deleteUserSession() throws
}

final class UserSessionDataStore: UserSessionDataStoreProtocol {
  
  // MARK: - Properties
  private let userSessionCoder: UserSessionCoding
  
  // MARK: - Initialization
  init(userSessionCoder: UserSessionCoding) {
    self.userSessionCoder = userSessionCoder
  }
  
  // MARK: - Methods
  func readUserSession() throws -> RemoteUserSession? {
    let query = KeychainItemQuery()
    if let data = try Keychain.findItem(query: query) {
      let userSession = self.userSessionCoder.decode(data: data)
      return userSession
    } else {
      return nil
    }
  }
  
  func save(userSession: RemoteUserSession) throws {
    let data = userSessionCoder.encode(userSession: userSession)
    let item = KeychainItemWithData(data: data)
    
    switch try readUserSession() {
    case .some(_):
      try Keychain.update(item: item)
    case .none:
      try Keychain.save(item: item)
    }
  }
  
  func deleteUserSession() throws {
    let item = KeychainItem()
    try Keychain.delete(item: item)
  }
}

enum UserSessionDataStoreError: Error {
  case typeCast
  case unknown
}
