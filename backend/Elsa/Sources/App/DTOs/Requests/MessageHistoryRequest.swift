//
//  MessageHistoryRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 26.10.2025.
//

import Vapor

struct MessageHistoryRequest: Content {
  let conversationId: Conversation.IDValue
  let count: Int
  let beforeMessageId: Message.IDValue?
  
  enum CodingKeys: String, CodingKey {
    case conversationId = "conversation_id"
    case count
    case beforeMessageId = "before_message_id"
  }
}
