//
//  MessageEvent.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.12.2024.
//

import Foundation

struct MessageEvent {
  let newMessage: Message?
  
  func toDTO() throws -> MessageEventDTO {
    .init(newMessage: try newMessage?.toDTO())
  }
}
