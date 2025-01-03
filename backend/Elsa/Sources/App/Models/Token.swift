//
//  Token.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 05.11.2024.
//

import Fluent
import struct Foundation.UUID

final class Token: Model, @unchecked Sendable {
  static let schema = "tokens"
  
  @ID
  var id: UUID?
  
  @Field(key: "value")
  var value: String
  
  @Parent(key: "user_id")
  var user: User
  
  init() { }
  
  init(id: UUID? = nil, value: String, userID: User.IDValue) {
    self.id = id
    self.value = value
    self.$user.id = userID
  }
}

extension Token {
  static func generate(for user: User) throws -> Token {
    let random = [UInt8].random(count: 16).base64
    return Token(value: random, userID: try user.requireID())
  }
}

extension Token: ModelTokenAuthenticatable {
  typealias User = App.User
  
  static let valueKey = \Token.$value
  static let userKey = \Token.$user
  
  var isValid: Bool {
    true
  }
}
