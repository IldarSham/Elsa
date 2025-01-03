//
//  UserSessionCoding.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 19.12.2024.
//

import Foundation

protocol UserSessionCoding {
  func encode(userSession: RemoteUserSession) -> Data
  func decode(data: Data) -> RemoteUserSession
}
