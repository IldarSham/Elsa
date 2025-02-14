//
//  ConversationEventDTO.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.12.2024.
//

import Vapor

struct ConversationEventDTO: Content, StreamableEvent {
  let newMessage: MessageDTO?
  let updatedTitle: UpdatedTitleDTO?
  
  static func emptyEvent() -> ConversationEventDTO {
    .init(newMessage: nil, updatedTitle: nil)
  }
}
