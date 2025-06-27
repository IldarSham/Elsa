//
//  ConversationsListViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 30.01.2025.
//

import Foundation
import Combine

@MainActor
final class ConversationsListViewModel: ObservableObject,
                                        NewConversationResponder,
                                        UpdatedConversationTitleResponder {
  // MARK: - Nested Types
  enum Section: Hashable, Comparable {
    case today, yesterday, last30Days, specificDate(Date)
    
    var title: String {
      switch self {
      case .today:
        return "Сегодня"
      case .yesterday:
        return "Вчера"
      case .last30Days:
        return "Последние 30 дней"
      case .specificDate(let date):
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM yyyy 'г.'"
        return formatter.string(from: date)
      }
    }
    
    private var order: Int {
      switch self {
      case .today:         return 3
      case .yesterday:     return 2
      case .last30Days:    return 1
      case .specificDate:  return 0
      }
    }
    
    private var dateValue: TimeInterval {
      if case .specificDate(let date) = self { return date.timeIntervalSince1970 }
      return 0
    }
    
    static func < (lhs: Section, rhs: Section) -> Bool {
      if lhs.order != rhs.order {
        return lhs.order < rhs.order
      }
      return lhs.dateValue < rhs.dateValue
    }
  }
  
  // MARK: - Dependencies
  private let conversationsLoader: LoadConversationsListUseCaseProtocol
  
  // MARK: - Published Properties
  @Published private(set) var conversationsBySection: [Section: [Conversation]] = [:]
  @Published public var selectedConversation: Conversation?
  @Published public var isLoading = false
  @Published public var isLoadingMore = false
  @Published public var isProfileSheetVisible = false
  
  // MARK: - Pagination State
  private var currentPage = 1
  private var totalConversations = 0
  private(set) var hasMoreConversations = false
  private let conversationsPerPage = 30
  
  // MARK: - Computed Properties
  public var conversationsListIsEmpty: Bool {
    conversationsBySection.isEmpty
  }
  
  public var sortedConversationsBySection: [(key: Section, value: [Conversation])] {
    conversationsBySection.sorted { $0.key > $1.key }
  }
  
  // MARK: - Initialization
  public init(conversationsLoader: LoadConversationsListUseCaseProtocol) {
    self.conversationsLoader = conversationsLoader
  }
  
  // MARK: - Public Methods
  
  public func loadConversations() async {
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }
    
    do {
      let page = try await conversationsLoader.load(page: currentPage, per: conversationsPerPage)
      processLoadedConversations(page)
    } catch {
      print(error)
    }
  }
  
  public func loadConversations() {
    Task { await loadConversations() }
  }
  
  public func selectConversation(_ conversation: Conversation) {
    selectedConversation = conversation
  }
  
  public func loadMoreConversations() {
    guard !isLoadingMore, hasMoreConversations else { return }
    Task {
      isLoadingMore = true
      defer { isLoadingMore = false }
      
      currentPage += 1
      try? await Task.sleep(for: .seconds(1))
      await loadConversations()
    }
  }
  
  public func refreshConversations() async {
    guard !isLoading else { return }
    currentPage = 1
    try? await Task.sleep(for: .seconds(1))
    await loadConversations()
  }
  
  // MARK: - NewConversationResponder
  
  public func newConversationAdded(_ conversation: Conversation) {
    var updatedConversation = conversation
    updatedConversation.title = conversation.title ?? "Новый чат"
    conversationsBySection[.today, default: []].insert(updatedConversation, at: 0)
    selectedConversation = conversation
  }
  
  // MARK: - UpdatedConversationTitleResponder
  
  public func updatedConversationTitle(_ updated: UpdatedTitle) {
    for section in conversationsBySection.keys {
      if let index = conversationsBySection[section]?.firstIndex(where: { $0.id == updated.conversation.id }) {
        conversationsBySection[section]?[index].title = updated.updatedTitle
        break
      }
    }
  }
  
  // MARK: - Private Methods
  
  private func processLoadedConversations(_ page: Page<Conversation>) {
    updateConversations(with: page.items, reset: currentPage == 1)
    totalConversations += page.items.count
    hasMoreConversations = totalConversations < page.metadata.total
  }
  
  private func updateConversations(with conversations: [Conversation], reset: Bool) {
    let newConversations = conversations.reduce(into: reset ? [Section: [Conversation]]() : conversationsBySection) { dict, conversation in
      let key = section(for: Date(timeIntervalSince1970: TimeInterval(conversation.createdAt)))
      dict[key, default: []].append(conversation)
    }
    conversationsBySection = newConversations
    totalConversations = reset ? conversations.count : totalConversations + conversations.count
  }
  
  private func section(for date: Date) -> Section {
    let calendar = Calendar.current
    if calendar.isDateInToday(date) { return .today }
    if calendar.isDateInYesterday(date) { return .yesterday }
    if let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day, daysAgo <= 30 {
      return .last30Days
    }
    return .specificDate(calendar.startOfDay(for: date))
  }
}
