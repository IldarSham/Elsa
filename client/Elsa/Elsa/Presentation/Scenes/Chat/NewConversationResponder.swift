//
//  NewConversationResponder.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 09.02.2025.
//

import Foundation
 
@MainActor
protocol NewConversationResponder {
  func newConversationAdded(_ conversation: Conversation)
}
