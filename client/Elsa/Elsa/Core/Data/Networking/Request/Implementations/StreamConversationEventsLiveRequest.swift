//
//  StreamConversationEventsLiveRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 18.12.2024.
//

import Foundation

struct StreamConversationEventsLiveRequest {
  let conversationId: UUID
}

extension StreamConversationEventsLiveRequest: LiveRequestProtocol {
  
  var path: String {
    "/conversations/\(conversationId)/stream"
  }
  
  var httpMethod: HTTPMethod {
    .get
  }
}
