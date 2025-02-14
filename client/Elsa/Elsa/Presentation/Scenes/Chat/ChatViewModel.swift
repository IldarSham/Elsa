//
//  ChatViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 13.12.2024.
//

import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
  
  // MARK: - Dependencies
  private let conversationCreator: CreateConversationUseCaseProtocol
  private let messageSender: SendMessageUseCaseProtocol
  private var newConversationResponder: NewConversationResponder
  
  // MARK: - Published Properties
  @Published var activeConversationId: UUID?
  @Published var messageInput: String = ""
  @Published var isSideMenuVisible: Bool = false
  @Published var lastErrorMessage: String = "" {
      didSet { isDisplayingError = true }
  }
  @Published var isDisplayingError: Bool = false
    
  // MARK: - Initialization
  init(conversationCreator: CreateConversationUseCaseProtocol,
       messageSender: SendMessageUseCaseProtocol,
       newConversationResponder: NewConversationResponder) {
    self.conversationCreator = conversationCreator
    self.messageSender = messageSender
    self.newConversationResponder = newConversationResponder
  }
  
  // MARK: - Public Methods
  
  public func startNewConversation() {
    activeConversationId = nil
  }
  
  public func selectConversation(_ conversation: Conversation) {
    activeConversationId = conversation.id
  }
  
  public func sendMessage() {
    let text = clearMessageInput()
    Task {
      do {
        let conversationId = try await ensureActiveConversation()
        try await messageSender.send(to: conversationId, text: text)
      } catch {
        handleError(error)
      }
    }
  }
  
  // MARK: - Private Methods
  
  private func ensureActiveConversation() async throws -> UUID {
    if let existingId = activeConversationId {
      return existingId
    }
    let newConversation = try await createNewConversation()
    activeConversationId = newConversation.id
    return newConversation.id
  }
  
  private func createNewConversation() async throws -> Conversation {
    let conversation = try await conversationCreator.create()
    newConversationResponder.newConversationAdded(conversation)
    return conversation
  }
  
  private func clearMessageInput() -> String {
    defer { messageInput = "" }
    return messageInput
  }
  
  private func handleError(_ error: Error) {
    lastErrorMessage = error.localizedDescription
  }
}
