//
//  ConversationDTO.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.01.2025.
//

import Vapor

struct ConversationDTO: Content {
  let id: Conversation.IDValue
  let createdAt: Int?
  let title: String?
}
