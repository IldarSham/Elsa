//
//  StreamMessageEventsLiveRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 18.12.2024.
//

import Foundation

struct StreamMessageEventsLiveRequest {
  let conversationId: UUID
}

extension StreamMessageEventsLiveRequest: LiveRequestProtocol {
  
  var path: String {
    "/messages/stream"
  }
  
  var httpMethod: HTTPMethod {
    .get
  }
  
  var queryItems: [String: String] {
    [
      "conversation_id": "\(conversationId)"
    ]
  }
}
