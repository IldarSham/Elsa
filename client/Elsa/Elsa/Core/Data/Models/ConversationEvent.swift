//
//  ConversationEvent.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.12.2024.
//

import Foundation

enum ConversationEvent: Decodable {
  case newMessage(Message)
  case updatedTitle(UpdatedTitle)
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    if container.contains(.newMessage) {
      self = .newMessage(try container.decode(Message.self, forKey: .newMessage))
    } else if container.contains(.updatedTitle) {
      self = .updatedTitle(try container.decode(UpdatedTitle.self, forKey: .updatedTitle))
    } else {
      throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                              debugDescription: "Unknown event type"))
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case newMessage
    case updatedTitle
  }
}
