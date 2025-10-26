//
//  SignedInDependencyContainer.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 19.12.2024.
//

import Foundation

@MainActor
final class SignedInDependencyContainer {
  
  // MARK: - Properties
  
  // From parent container
  let sharedUserSessionDataStore: UserSessionDataStoreProtocol
  let sharedMainViewModel: MainViewModel
  let sharedRemoteAPIManager: RemoteAPIManagerProtocol
  
  // Long-lived dependencies
  let sharedMessagesRemoteAPI: MessagesRemoteAPIProtocol
  let sharedConversationsRemoteAPI: ConversationsRemoteAPIProtocol
  let sharedConversationsListViewModel: ConversationsListViewModel
  
  // Cache
  var conversationsListView: ConversationsListView?
  var conversationsViews: [UUID: ConversationView] = [:]

  // Context
  let userSession: RemoteUserSession
  
  init(userSession: RemoteUserSession, appDependencyContainer: AppDependencyContainer) {
    func makeMessagesRemoteAPI(apiManager: RemoteAPIManagerProtocol) -> MessagesRemoteAPIProtocol {
      return MessagesRemoteAPI(userSession: userSession,
                               apiManager: apiManager)
    }
    func makeConversationsRemoteAPI(apiManager: RemoteAPIManagerProtocol) -> ConversationsRemoteAPIProtocol {
      return ConversationsRemoteAPI(userSession: userSession,
                                    apiManager: apiManager)
    }
    func makeLoadConversationsListUseCase(remoteAPI: ConversationsRemoteAPIProtocol) -> LoadConversationsListUseCaseProtocol {
      return LoadConversationsListUseCase(remoteAPI: remoteAPI)
    }
    func makeConversationsListViewModel(remoteAPI: ConversationsRemoteAPIProtocol) -> ConversationsListViewModel {
      let useCase = makeLoadConversationsListUseCase(remoteAPI: remoteAPI)
      return ConversationsListViewModel(conversationsLoader: useCase)
    }
    
    self.userSession = userSession
    
    self.sharedUserSessionDataStore = appDependencyContainer.sharedUserSessionDataStore
    self.sharedMainViewModel = appDependencyContainer.sharedMainViewModel
    self.sharedRemoteAPIManager = appDependencyContainer.sharedRemoteAPIManager
    
    self.sharedMessagesRemoteAPI = makeMessagesRemoteAPI(apiManager: sharedRemoteAPIManager)
    self.sharedConversationsRemoteAPI = makeConversationsRemoteAPI(apiManager: sharedRemoteAPIManager)
    self.sharedConversationsListViewModel = makeConversationsListViewModel(remoteAPI: sharedConversationsRemoteAPI)
  }
  
  public func makeSignedInView() -> SignedInView {
    let viewModel = makeSignedInViewModel()
    return SignedInView(viewModel: viewModel, chatViewFactory: self)
  }
  
  public func makeSignedInViewModel() -> SignedInViewModel {
    return SignedInViewModel(userSession: userSession)
  }
  
  public func makeMessagesRemoteAPI() -> MessagesRemoteAPIProtocol {
    return MessagesRemoteAPI(userSession: userSession,
                             apiManager: sharedRemoteAPIManager)
  }
}
 
// MARK: - ChatViewFactory
extension SignedInDependencyContainer: ChatViewFactory {
  
  public func makeChatView() -> ChatView {
    let viewModel = makeChatViewModel()
    return ChatView(viewModel: viewModel,
                    conversationsListViewFactory: self,
                    conversationViewFactory: self)
  }

  public func makeChatViewModel() -> ChatViewModel {
    let createConversationUseCase = makeCreateConversationUseCase()
    let sendMessageUseCase = makeSendMessageUseCase()
    return ChatViewModel(conversationCreator: createConversationUseCase,
                         messageSender: sendMessageUseCase,
                         newConversationResponder: sharedConversationsListViewModel)
  }

  public func makeCreateConversationUseCase() -> CreateConversationUseCaseProtocol {
    return CreateConversationUseCase(remoteAPI: sharedConversationsRemoteAPI)
  }
  
  public func makeSendMessageUseCase() -> SendMessageUseCaseProtocol {
    return SendMessageUseCase(remoteAPI: sharedMessagesRemoteAPI)
  }
}

// MARK: - ConversationsListViewFactory
extension SignedInDependencyContainer: ConversationsListViewFactory {
  
  public func makeConversationsListView(didSelectConversation: ((Conversation) -> Void)?,
                                        didTapNewChat: (() -> Void)?) -> ConversationsListView {
    if let cached = conversationsListView {
      return cached
    }
    let view = ConversationsListView(viewModel: sharedConversationsListViewModel,
                                     didSelectConversation: didSelectConversation,
                                     didTapNewChat: didTapNewChat,
                                     profileViewFactory: self)
    conversationsListView = view
    return view
  }
}

// MARK: - ConversationViewFactory
extension SignedInDependencyContainer: ConversationViewFactory {
  
  public func makeConversationView(conversationId: UUID) -> ConversationView {
    if let cached = conversationsViews[conversationId] {
      return cached
    }
    let viewModel = makeConversationViewModel(conversationId: conversationId)
    let view = ConversationView(viewModel: viewModel)
    conversationsViews[conversationId] = view
    return view
  }
  
  public func makeConversationViewModel(conversationId: UUID) -> ConversationViewModel {
    let loadMessagesListUseCase = makeLoadMessagesListUseCase()
    let streamConversationEventsUseCase = makeStreamConversationEventsUseCase()
    return ConversationViewModel(conversationId: conversationId,
                                 messagesLoader: loadMessagesListUseCase,
                                 eventsStreamer: streamConversationEventsUseCase,
                                 titleUpdateResponder: sharedConversationsListViewModel)
  }

  public func makeLoadMessagesListUseCase() -> LoadMessageHistoryUseCaseProtocol {
    return LoadMessagesListUseCase(remoteAPI: sharedMessagesRemoteAPI)
  }
  
  public func makeStreamConversationEventsUseCase() -> StreamConversationEventsUseCaseProtocol {
    return StreamConversationEventsUseCase(remoteAPI: sharedConversationsRemoteAPI)
  }
}

// MARK: - SettingsViewFactory
extension SignedInDependencyContainer: ProfileViewFactory {
  
  public func makeProfileView() -> ProfileView {
    let viewModel = makeProfileViewModel()
    return ProfileView(viewModel: viewModel)
  }
  
  public func makeProfileViewModel() -> ProfileViewModel {
    let useCase = makeLogoutUseCase()
    return ProfileViewModel(logoutUseCase: useCase,
                            notSignedInResponder: sharedMainViewModel)
  }
  
  public func makeLogoutUseCase() -> LogoutUseCaseProtocol {
    return LogoutUseCase(dataStore: sharedUserSessionDataStore)
  }
}
