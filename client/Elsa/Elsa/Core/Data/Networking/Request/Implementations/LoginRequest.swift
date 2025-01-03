//
//  LoginRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 16.12.2024.
//

import Foundation

struct LoginRequest: Encodable {
  let email: String
  let password: String
}

// MARK: - RequestProtocol
extension LoginRequest: RequestProtocol {
  
  var path: String {
    "/users/login"
  }
  
  var httpMethod: HTTPMethod {
    .post
  }
  
  var headers: [String: String] {
    [
      "Authorization": generateAuthString()
    ]
  }
  
  var addAuthorizationToken: Bool {
    false
  }
}

extension LoginRequest {
  
  private func generateAuthString() -> String {
    let userPasswordData = "\(email):\(password)".data(using: .utf8)!
    let base64EncodedCredential = userPasswordData.base64EncodedString(options: [])
    let authString = "Basic \(base64EncodedCredential)"
    return authString
  }
}
