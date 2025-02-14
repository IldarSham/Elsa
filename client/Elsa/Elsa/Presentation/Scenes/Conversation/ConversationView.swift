//
//  ConversationView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.01.2025.
//

import SwiftUI

struct ConversationView: View {
  
  // MARK: - Properties
  @ObservedObject var viewModel: ConversationViewModel
  @State private var scrolledID: Message.ID?
  
  // MARK: - Body
  var body: some View {
    ScrollView {
      if viewModel.isLoadingMore {
        PrimaryProgressView()
          .padding()
      }
      
      LazyVStack(spacing: 20) {
        ForEach(viewModel.messages) { message in
          MessageView(viewModel: viewModel.viewModel(for: message))
        }
        .onChange(of: viewModel.messages.last) {
          guard let last = viewModel.messages.last else { return }
          
          withAnimation(.easeOut) {
            scrolledID = last.id
          }
        }
        .onChange(of: scrolledID) {
          if scrolledID == viewModel.messages.first?.id {
            viewModel.loadMoreMessages()
          }
        }
      }
      .scrollTargetLayout()
    }
    .scrollIndicators(.visible)
    .scrollPosition(id: $scrolledID)
    .defaultScrollAnchor(.bottom)
    .padding(.vertical, 20)
    .task {
      await viewModel.startEventsStreaming()
    }
    .task {
      if viewModel.messages.isEmpty {
        await viewModel.loadMessages()
      }
    }
  }
}

@MainActor
protocol ConversationViewFactory {
  func makeConversationView(conversationId: UUID) -> ConversationView
}
