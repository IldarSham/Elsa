//
//  SignedInView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 16.12.2024.
//

import SwiftUI

struct SignedInView: View {
  
  // MARK: - Properties
  let viewModel: SignedInViewModel
  let chatViewFactory: ChatViewFactory
  
  var body: some View {
    chatViewFactory.makeChatView()
  }
}

@MainActor
protocol SignedInViewFactory {
  func makeSignedInView(userSession: RemoteUserSession) -> SignedInView
}
