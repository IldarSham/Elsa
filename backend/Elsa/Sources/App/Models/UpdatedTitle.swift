//
//  UpdatedTitle.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 10.02.2025.
//

import Vapor

struct UpdatedTitle: Content {
  let conversation: Conversation
  let updatedTitle: String
  
  func toDTO() throws -> UpdatedTitleDTO {
    .init(conversation: try conversation.toDTO(),
          updatedTitle: updatedTitle)
  }
}
