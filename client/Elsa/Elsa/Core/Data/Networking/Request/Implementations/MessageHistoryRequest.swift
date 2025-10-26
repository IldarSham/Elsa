//
//  MessageHistoryRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 22.12.2024.
//

import Foundation

struct MessageHistoryRequest {
  let conversationId: UUID
  let count: Int
  let beforeMessageId: Int?
}

extension MessageHistoryRequest: RequestProtocol {
  
  var path: String {
    "/messages"
  }
  
  var httpMethod: HTTPMethod {
    .get
  }
  
  var queryItems: [String: String?] {
    [
      "conversation_id": "\(conversationId)",
      "count": "\(count)",
      "before_message_id": beforeMessageId.map { "\($0)" }
    ]
  }
}
