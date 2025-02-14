//
//  UpdatedConversationTitleResponder.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 09.02.2025.
//

import Foundation

@MainActor
protocol UpdatedConversationTitleResponder {
  func updatedConversationTitle(_ updated: UpdatedTitle)
}
