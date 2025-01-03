//
//  MessageEventDTO.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.12.2024.
//

import Vapor

struct MessageEventDTO: Content, StreamableEvent {
  let newMessage: MessageDTO?
  
  static func emptyEvent() -> MessageEventDTO {
    .init(newMessage: nil)
  }
}
