//
//  RegisterRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 16.12.2024.
//

import Foundation

struct RegisterRequest: Encodable {
  let firstName: String
  let lastName: String
  let email: String
  let password: String
}

extension RegisterRequest: RequestProtocol {
  
  var path: String {
    "/users/register"
  }
  
  var httpMethod: HTTPMethod {
    .post
  }
  
  var addAuthorizationToken: Bool {
    false
  }
}
