//
//  ConversationViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 27.01.2025.
//

import Foundation

@MainActor
final class ConversationViewModel: ObservableObject {
  
  // MARK: - Dependencies
  private let conversationId: UUID
  private let messagesLoader: LoadMessageHistoryUseCaseProtocol
  private let eventsStreamer: StreamConversationEventsUseCaseProtocol
  private let titleUpdateResponder: UpdatedConversationTitleResponder
  
  // MARK: - Published Properties
  @Published private(set) var messages: [Message] = []
  @Published var isLoading = false
  @Published var isLoadingMore = false
  @Published var lastErrorMessage = "" {
      didSet { isDisplayingError = true }
  }
  @Published var isDisplayingError = false
  
  // MARK: - Private Properties
  private var hasMoreMessages = false

  // MARK: - Initialization
  init(conversationId: UUID,
       messagesLoader: LoadMessageHistoryUseCaseProtocol,
       eventsStreamer: StreamConversationEventsUseCaseProtocol,
       titleUpdateResponder: UpdatedConversationTitleResponder) {
    self.conversationId = conversationId
    self.messagesLoader = messagesLoader
    self.eventsStreamer = eventsStreamer
    self.titleUpdateResponder = titleUpdateResponder
  }
  
  // MARK: - Public Methods
  
  public func startEventsStreaming() async {
    do {
      let stream = try await eventsStreamer.stream(for: conversationId)
      for await event in stream {
        process(event: event)
      }
    } catch {
      handleError(error)
    }
  }
  
  func loadMessages() async {
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }

    do {
      let response = try await messagesLoader.load(
        for: conversationId,
        count: 30,
        beforeMessageId: messages.first?.id
      )
      process(response)
    } catch {
      handleError(error)
    }
  }
  
  public func loadMoreMessages() {
    guard !isLoadingMore, hasMoreMessages else { return }
    
    Task {
      isLoadingMore = true
      defer { isLoadingMore = false }

      try await Task.sleep(for: .seconds(1))
      await loadMessages()
    }
  }
  
  public func viewModel(for message: Message) -> MessageViewModel {
    MessageViewModel(
      text: message.content,
      sentByMe: message.sender == .user
    )
  }
  
  // MARK: - Private Methods

  private func process(event: ConversationEvent) {
    switch event {
    case .newMessage(let message):
      handle(newMessage: message)
    case .updatedTitle(let updatedTitle):
      handle(updatedTitle: updatedTitle)
    }
  }
  
  private func handle(newMessage: Message) {
    messages.append(newMessage)
  }
  
  private func handle(updatedTitle: UpdatedTitle) {
    titleUpdateResponder.updatedConversationTitle(updatedTitle)
  }

  private func process(_ response: MessageHistory) {
    messages.insert(contentsOf: response.messages, at: 0)
    hasMoreMessages = response.hasMore
  }
  
  private func handleError(_ error: Error) {
    lastErrorMessage = error.localizedDescription
  }
}
