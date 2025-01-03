//
//  RegisterUserRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 05.11.2024.
//

import Vapor

struct RegisterUserRequest: Content {
  let firstName: String
  let lastName: String
  let email: String
  let password: String
}
