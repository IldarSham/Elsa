//
//  MessagesListRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 22.12.2024.
//

import Foundation

struct MessagesListRequest {
  let conversationId: UUID
  let page: Int
  let per: Int
}

extension MessagesListRequest: RequestProtocol {
  
  var path: String {
    "/messages"
  }
  
  var httpMethod: HTTPMethod {
    .get
  }
  
  var queryItems: [String: String] {
    [
      "conversation_id": "\(conversationId)",
      "page": "\(page)",
      "per": "\(per)"
    ]
  }
}
