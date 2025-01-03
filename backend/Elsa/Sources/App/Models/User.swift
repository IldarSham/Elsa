//
//  User.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 05.11.2024.
//

import Fluent
import Vapor

final class User: Model, @unchecked Sendable {
  static let schema = "users"
  
  @ID(custom: "id")
  var id: Int?
  
  @Field(key: "first_name")
  var firstName: String
  
  @Field(key: "last_name")
  var lastName: String
  
  @Field(key: "email")
  var email: String
  
  @Field(key: "password_hash")
  var passwordHash: String
  
  @Children(for: \.$creator)
  var conversations: [Conversation]
  
  init() { }
  
  init(id: Int? = nil, firstName: String, lastName: String, email: String, passwordHash: String) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
    self.passwordHash = passwordHash
  }
  
  func toDTO() throws -> UserDTO {
    .init(id: try self.requireID())
  }
}

extension User {
  static func create(from registerData: RegisterUserRequest) throws -> User {
    User(firstName: registerData.firstName,
         lastName: registerData.lastName,
         email: registerData.email,
         passwordHash: try Bcrypt.hash(registerData.password))
  }
}

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$email
  static let passwordHashKey = \User.$passwordHash
  
  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.passwordHash)
  }
}
