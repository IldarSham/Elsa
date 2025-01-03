//
//  SignedInView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 16.12.2024.
//

import SwiftUI

struct SignedInView: View {
  
  let viewModel: SignedInViewModel
  
  // Factories
  let chatViewFactory: ChatViewFactory
  
  var body: some View {
    chatViewFactory.makeChatView(conversationId: viewModel.initialConversationId)
  }
}

@MainActor
protocol SignedInViewFactory {
  func makeSignedInView(userSession: RemoteUserSession) -> SignedInView
}
