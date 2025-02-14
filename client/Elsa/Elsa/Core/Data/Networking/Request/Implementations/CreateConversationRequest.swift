//
//  CreateConversationRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.01.2025.
//

import Foundation

struct CreateConversationRequest: RequestProtocol {
  
  var path: String {
    "/conversations/create"
  }
  
  var httpMethod: HTTPMethod {
    .post
  }
}
