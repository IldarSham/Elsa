//
//  MessageDTO.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 14.12.2024.
//

import Vapor

struct MessageDTO: Content {
  let id: Message.IDValue
  let createdAt: Int?
  let conversationId: Conversation.IDValue
  let sender: MessageSender
  let content: String
}
