//
//  MessageSendRequest.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 14.12.2024.
//

import Vapor

struct MessageSendRequest: Content {
  let conversationId: Conversation.IDValue
  let content: String
}
