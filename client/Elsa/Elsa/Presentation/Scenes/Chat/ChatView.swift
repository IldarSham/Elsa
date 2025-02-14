//
//  ChatView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 01.12.2024.
//

import SwiftUI

struct ChatView: View {
  
  // MARK: - Constants
  private enum Constants {
    static let sideMenuWidthRatio: CGFloat = 0.75
  }
  
  // MARK: - Properties
  @ObservedObject private var viewModel: ChatViewModel
  private let conversationFactory: ConversationViewFactory
  private let conversationsListView: ConversationsListView
  
  // MARK: - Initialization
  public init(
    viewModel: ChatViewModel,
    conversationsListViewFactory: ConversationsListViewFactory,
    conversationViewFactory: ConversationViewFactory
  ) {
    self.viewModel = viewModel
    self.conversationFactory = conversationViewFactory
    self.conversationsListView = Self.createConversationsListView(
      from: conversationsListViewFactory,
      viewModel: viewModel
    )
  }
  
  // MARK: - Body
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        mainChatNavigationView(in: geometry)
        
        if viewModel.isSideMenuVisible {
          conversationsListView
            .frame(width: geometry.size.width * Constants.sideMenuWidthRatio)
            .transition(.move(edge: .leading))
        }
      }
      .gesture(dragGesture)
    }
  }
  
  // MARK: - Main Chat View
  private func mainChatNavigationView(in geometry: GeometryProxy) -> some View {
    NavigationView {
      VStack(spacing: 0) {
        chatContent
        messageInputArea
      }
      .disabled(viewModel.isSideMenuVisible)
      .navigationTitle("Elsa")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        sideMenuToggleButton
        newConversationToolbarButton
      }
      .overlay(
        viewModel.isSideMenuVisible ? Color.black.opacity(0.3) : Color.clear
      )
    }
    .offset(x: viewModel.isSideMenuVisible ? geometry.size.width * Constants.sideMenuWidthRatio : 0)
    .animation(.easeInOut, value: viewModel.isSideMenuVisible)
  }
  
  // MARK: - Gestures
  private var dragGesture: some Gesture {
    DragGesture().onEnded { value in
      if value.location.x < 200,
         abs(value.translation.height) < 50,
         abs(value.translation.width) > 50 {
        withAnimation {
          viewModel.isSideMenuVisible = value.translation.width > 0
        }
      }
    }
  }
  
  // MARK: - Chat Content
  @ViewBuilder
  private var chatContent: some View {
    if let conversationId = viewModel.activeConversationId {
      conversationFactory.makeConversationView(conversationId: conversationId)
        .id(conversationId)
    } else {
      emptyChatState
    }
  }
  
  private var emptyChatState: some View {
    Text("Задайте мне вопрос")
      .font(.title)
      .bold()
      .foregroundStyle(
        LinearGradient(
          colors: [Color.primaryBlue, Color.lightBlue],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .frame(maxHeight: .infinity, alignment: .center)
  }
  
  // MARK: - Message Input Area
  private var messageInputArea: some View {
    HStack(alignment: .bottom, spacing: 12) {
      MessageTextField(placeholder: "Как вам помочь?", text: $viewModel.messageInput)
      
      Button(action: viewModel.sendMessage) {
        Image(systemName: "arrow.up.circle.fill")
          .resizable()
          .frame(width: 35, height: 35)
          .padding(.bottom, 6)
          .foregroundColor(
            viewModel.messageInput.isEmpty
            ? Color.primaryBlue.opacity(0.4)
            : Color.primaryBlue
          )
      }
      .disabled(viewModel.messageInput.isEmpty)
    }
    .padding(.horizontal, 15)
    .padding(.vertical, 20)
  }
  
  // MARK: - Toolbar Items
  private var sideMenuToggleButton: some ToolbarContent {
    ToolbarItemGroup(placement: .topBarLeading) {
      Button {
        withAnimation { viewModel.isSideMenuVisible.toggle() }
      } label: {
        SideMenuIcon()
      }
    }
  }
  
  private var newConversationToolbarButton: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: viewModel.startNewConversation) {
        Image(systemName: "square.and.pencil")
          .tint(.black)
      }
    }
  }
  
  // MARK: - Helper Methods
  private static func createConversationsListView(
    from factory: ConversationsListViewFactory,
    viewModel: ChatViewModel
  ) -> ConversationsListView {
    factory.makeConversationsListView(
      didSelectConversation: { conversation in
        viewModel.selectConversation(conversation)
        viewModel.isSideMenuVisible = false
      },
      didTapNewChat: {
        viewModel.isSideMenuVisible = false
      }
    )
  }
}


@MainActor
protocol ChatViewFactory {
  func makeChatView() -> ChatView
}
