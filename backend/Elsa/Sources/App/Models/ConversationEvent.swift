//
//  ConversationEvent.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.12.2024.
//

import Foundation

struct ConversationEvent {
  var newMessage: Message?
  var updatedTitle: UpdatedTitle?
  
  func toDTO() throws -> ConversationEventDTO {
    .init(newMessage: try newMessage?.toDTO(),
          updatedTitle: try updatedTitle?.toDTO())
  }
}
