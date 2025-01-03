//
//  SendMessageRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 21.12.2024.
//

import Foundation

struct SendMessageRequest: Encodable {
  let conversationId: UUID
  let content: String
}

extension SendMessageRequest: RequestProtocol {
  var path: String {
    "/messages/send"
  }
  
  var httpMethod: HTTPMethod {
    .post
  }
}
