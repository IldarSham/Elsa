//
//  UserSessionPropertyListCoder.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 19.12.2024.
//

import Foundation

final class UserSessionPropertyListCoder: UserSessionCoding {
  
  // MARK: - Methods
  func encode(userSession: RemoteUserSession) -> Data {
    return try! PropertyListEncoder().encode(userSession)
  }
  
  func decode(data: Data) -> RemoteUserSession {
    return try! PropertyListDecoder().decode(RemoteUserSession.self, from: data)
  }
}
