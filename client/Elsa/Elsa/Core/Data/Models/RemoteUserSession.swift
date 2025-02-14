//
//  RemoteUserSession.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 16.12.2024.
//

import Foundation

struct RemoteUserSession: Codable {
  let token: String
  let user: User
}
