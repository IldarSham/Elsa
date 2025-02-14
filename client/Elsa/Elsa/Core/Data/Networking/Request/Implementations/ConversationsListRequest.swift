//
//  ConversationsListRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 29.01.2025.
//

import Foundation

struct ConversationsListRequest {
  let page: Int
  let per: Int
}

extension ConversationsListRequest: RequestProtocol {
  
  var path: String {
    "/conversations"
  }
  
  var httpMethod: HTTPMethod {
    .get
  }
  
  var queryItems: [String: String] {
    [
      "page": "\(page)",
      "per": "\(per)"
    ]
  }
}
