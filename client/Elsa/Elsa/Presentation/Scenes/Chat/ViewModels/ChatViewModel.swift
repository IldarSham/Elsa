//
//  ChatViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 13.12.2024.
//

import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
  
  // MARK: - Published Properties
  @Published private(set) var messages: [Message] = []
  @Published public var messageInput: String = ""
  @Published public var isLoading: Bool = false
  @Published public var isLoadingMore: Bool = false
  @Published public var isSettingsVisible: Bool = false
  @Published public var lastErrorMessage = "" {
    didSet {
      isDisplayingError = true
    }
  }
  @Published public var isDisplayingError = false
  
  // MARK: - Computed Properties
  public var hasMessages: Bool {
    !messages.isEmpty
  }
  
  // MARK: - Private Properties
  private(set) var currentPage = 1
  private(set) var hasMoreMessages = false
  private let messagesPerPage = 30
  private let conversationId: UUID
  private let loadMessagesListUseCase: LoadMessagesListUseCaseProtocol
  private let streamMessageEventsUseCase: StreamMessageEventsUseCaseProtocol
  private let sendMessageUseCase: SendMessageUseCaseProtocol
  
  // MARK: - Initialization
  init(
    conversationId: UUID,
    loadMessagesListUseCase: LoadMessagesListUseCaseProtocol,
    streamMessageEventsUseCase: StreamMessageEventsUseCaseProtocol,
    sendMessageUseCase: SendMessageUseCaseProtocol
  ) {
    self.conversationId = conversationId
    self.loadMessagesListUseCase = loadMessagesListUseCase
    self.streamMessageEventsUseCase = streamMessageEventsUseCase
    self.sendMessageUseCase = sendMessageUseCase
  }
  
  // MARK: - Public Methods
  public func startMessageStreaming() async {
    do {
      let stream = try await streamMessageEventsUseCase.stream(for: conversationId)
      
      for await event in stream {
        guard let message = event.newMessage else { continue }
        handleNewMessage(message)
      }
    } catch {
      handleError(error)
    }
  }
  
  public func loadMessages() async {
    guard !isLoading else { return }
    
    do {
      isLoading = true
      defer { isLoading = false }
      
      let messages = try await loadMessagesListUseCase.load(
        for: conversationId,
        page: currentPage,
        per: messagesPerPage
      )
      processLoadedMessages(response: messages)
    } catch {
      handleError(error)
    }
  }
  
  public func loadMoreMessages() {
    guard !isLoadingMore && hasMoreMessages else { return }
        
    Task {
      isLoadingMore = true
      defer { isLoadingMore = false }
      
      currentPage += 1
      
      try await Task.sleep(for: .seconds(1))
      await loadMessages()
    }
  }
  
  public func sendMessage() {
    let text = clearMessageInputText()

    Task {
      do {
        try await sendMessageUseCase.send(to: conversationId, text: text)
      } catch {
        handleError(error)
      }
    }
  }
  
  public func getMessageViewModel(for message: Message) -> MessageViewModel {
    return MessageViewModel(text: message.content,
                            sentByMe: message.sender == .user)
  }
  
  // MARK: - Private Methods
  private func handleNewMessage(_ message: Message) {
    messages.append(message)
  }

  private func processLoadedMessages(response: Page<Message>) {
    messages.insert(contentsOf: response.items, at: 0)
    hasMoreMessages = messages.count < response.metadata.total
  }
  
  private func handleError(_ error: Error) {
    lastErrorMessage = error.localizedDescription
  }
  
  private func clearMessageInputText() -> String {
    defer { messageInput = "" }
    return messageInput
  }
}
