//
//  ChatView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 01.12.2024.
//

import SwiftUI

struct ChatView: View {
  
  @ObservedObject var viewModel: ChatViewModel
  let settingsViewFactory: SettingsViewFactory
  
  @State private var scrolledID: Message.ID?
  
  var body: some View {
    NavigationView {
      VStack {
        if viewModel.hasMessages {
          messagesListView
        } else {
          emptyStateView
        }
        messageInputView
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Elsa")
      .toolbar { settingsButton }
      .sheet(isPresented: $viewModel.isSettingsVisible) {
        settingsViewFactory.makeSettingsView()
      }
      .task {
        await viewModel.startMessageStreaming()
      }
      .task {
        await viewModel.loadMessages()
      }
    }
  }
  
  private var messagesListView: some View {
    ScrollView {
      if viewModel.isLoadingMore {
        ProgressView()
          .tint(Color.primaryBlue)
          .padding()
      }
      
      LazyVStack(spacing: 20) {
        ForEach(viewModel.messages) { message in
          MessageView(viewModel: viewModel.getMessageViewModel(for: message))
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
    .scrollPosition(id: $scrolledID)
    .defaultScrollAnchor(.bottom)
    .padding(.vertical, 20)
  }
  
  private var emptyStateView: some View {
    Text("Задайте мне вопрос")
      .bold()
      .font(.title)
      .foregroundStyle(
        .linearGradient(
          colors: [
            Color.primaryBlue,
            Color.lightBlue
          ],
          startPoint: .leading,
          endPoint: .trailing
        ))
      .frame(maxHeight: .infinity, alignment: .center)
  }
  
  private var messageInputView: some View {
    HStack(alignment: .bottom, spacing: 12) {
      MessageTextField(placeholder: "Как вам помочь?", text: $viewModel.messageInput)
      
      Button(action: viewModel.sendMessage) {
        Image(systemName: "arrow.up.circle.fill")
          .resizable()
          .tint(Color.primaryBlue)
          .frame(width: 35, height: 35)
          .padding(.bottom, 6)
      }
      .disabled(viewModel.messageInput.isEmpty)
    }
    .padding(.horizontal, 15)
    .padding(.vertical, 20)
  }
  
  private var settingsButton: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: {
        viewModel.isSettingsVisible = true
      }) {
        Image(systemName: "gearshape.fill")
          .tint(Color(UIColor.darkGray))
      }
    }
  }
}

@MainActor
protocol ChatViewFactory {
  func makeChatView(conversationId: UUID) -> ChatView
}
