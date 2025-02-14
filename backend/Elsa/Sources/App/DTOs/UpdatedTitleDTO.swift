//
//  UpdatedTitleDTO.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 10.02.2025.
//

import Vapor

struct UpdatedTitleDTO: Content {
  let conversation: ConversationDTO
  let updatedTitle: String
}
