//
//  ConversationsListView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 29.01.2025.
//

import SwiftUI

struct ConversationsListView: View {
  
  // MARK: - Constants
  private enum Constants {
    static let selectedBackgroundColor = Color(red: 223/255, green: 237/255, blue: 253/255)
    static let selectedTextColor = Color(red: 0/255, green: 98/255, blue: 238/255)
  }
  
  // MARK: - Properties
  @ObservedObject var viewModel: ConversationsListViewModel
  let profileViewFactory: ProfileViewFactory
  var didSelectConversation: ((Conversation) -> Void)?
  var didTapNewChat: (() -> Void)?
  
  // MARK: - Initialization
  public init(viewModel: ConversationsListViewModel,
              didSelectConversation: ((Conversation) -> Void)? = nil,
              didTapNewChat: (() -> Void)?,
              profileViewFactory: ProfileViewFactory) {
    self.viewModel = viewModel
    self.didSelectConversation = didSelectConversation
    self.didTapNewChat = didTapNewChat
    self.profileViewFactory = profileViewFactory
    viewModel.loadConversations()
  }
  
  // MARK: - Body
  var body: some View {
    VStack(alignment: .leading) {
      conversationListContent
      Divider()
      profileButton
    }
    .background(.white)
  }
  
  // MARK: - Subviews
  @ViewBuilder
  private var conversationListContent: some View {
    if !viewModel.conversationsListIsEmpty {
      conversationsList
    } else {
      emptyConversationsListState
    }
  }
  
  private var conversationsList: some View {
    List {
      ForEach(viewModel.sortedConversationsBySection, id: \.key) { group in
        Section(header: Text(group.key.title)) {
          ForEach(group.value, id: \.id) { conversation in
            conversationRow(for: conversation)
          }
        }
      }
      if viewModel.hasMoreConversations {
        ProgressView()
          .id(UUID())
          .listRowSeparator(.hidden)
          .onAppear(perform: viewModel.loadMoreConversations)
      }
    }
    .listSectionSpacing(3.0)
    .listStyle(.plain)
    .scrollIndicators(.visible)
    .padding(.top)
    .refreshable {
      await viewModel.refreshConversations()
    }
  }
  
  private var emptyConversationsListState: some View {
    VStack(spacing: 25) {
      VStack(spacing: 12) {
        Text("Список диалогов пуст")
          .font(.title2)
        Text("Начните новый чат\nпрямо сейчас")
          .multilineTextAlignment(.center)
          .foregroundStyle(.gray)
      }
      
      Button("Новый чат") {
        didTapNewChat?()
      }
      .font(.headline)
      .foregroundStyle(.white)
      .padding(10)
      .background(Color.primaryBlue)
      .cornerRadius(10)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
  }
  
  private func conversationRow(for conversation: Conversation) -> some View {
    HStack {
      Text(conversation.title ?? "")
        .font(.callout)
        .foregroundColor(isConversationSelected(conversation)
                         ? Constants.selectedTextColor
                         : .black)
      Spacer()
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 12)
    .background(isConversationSelected(conversation)
                ? Constants.selectedBackgroundColor
                : Color.clear)
    .cornerRadius(8)
    .contentShape(Rectangle())
    .onTapGesture {
      viewModel.selectConversation(conversation)
      didSelectConversation?(conversation)
    }
    .listRowSeparator(.hidden)
    .listRowInsets(EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8))
  }
  
  private var profileButton: some View {
    Button {
      viewModel.isProfileSheetVisible = true
    } label: {
      Image(systemName: "person.crop.circle.fill")
        .resizable()
        .frame(width: 30, height: 30)
        .foregroundColor(Color(UIColor.systemGray3))
    }
    .padding(.horizontal, 15)
    .padding(.vertical, 8)
    .sheet(isPresented: $viewModel.isProfileSheetVisible) {
      profileViewFactory.makeProfileView()
    }
  }
  
  // MARK: - Helpers
  private func isConversationSelected(_ conversation: Conversation) -> Bool {
    viewModel.selectedConversation?.id == conversation.id
  }
}

@MainActor
protocol ConversationsListViewFactory {
  func makeConversationsListView(didSelectConversation: ((Conversation) -> Void)?,
                                 didTapNewChat: (() -> Void)?) -> ConversationsListView
}
