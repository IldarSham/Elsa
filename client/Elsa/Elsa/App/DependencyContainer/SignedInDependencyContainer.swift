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
  let sharedMessagesRemoteAPI: MessagesRemoteAPIProtocol

  // Context
  let userSession: RemoteUserSession
  
  init(userSession: RemoteUserSession, appDependencyContainer: AppDependencyContainer) {
    self.userSession = userSession
    self.sharedUserSessionDataStore = appDependencyContainer.sharedUserSessionDataStore
    self.sharedMainViewModel = appDependencyContainer.sharedMainViewModel
    self.sharedRemoteAPIManager = appDependencyContainer.sharedRemoteAPIManager
    self.sharedMessagesRemoteAPI = MessagesRemoteAPI(userSession: userSession,
                                                     apiManager: sharedRemoteAPIManager)
  }
  
  public func makeSignedInView() -> SignedInView {
    let viewModel = makeSignedInViewModel()
    return SignedInView(viewModel: viewModel, chatViewFactory: self)
  }
  
  func makeSignedInViewModel() -> SignedInViewModel {
    return SignedInViewModel(userSession: userSession)
  }
  
  func makeMessagesRemoteAPI() -> MessagesRemoteAPIProtocol {
    return MessagesRemoteAPI(userSession: userSession,
                             apiManager: sharedRemoteAPIManager)
  }
}
 
// MARK: - ChatViewFactory
extension SignedInDependencyContainer: ChatViewFactory {
  
  func makeChatView(conversationId: UUID) -> ChatView {
    let viewModel = makeChatViewModel(conversationId: conversationId)
    return ChatView(viewModel: viewModel,
                    settingsViewFactory: self)
  }
  
  func makeChatViewModel(conversationId: UUID) -> ChatViewModel {
    let loadMessagesListUseCase = makeLoadMessagesListUseCase()
    let streamMessageEventsUseCase = makeStreamMessageEventsUseCase()
    let sendMessageUseCase = makeSendMessageUseCase()
    return ChatViewModel(conversationId: conversationId,
                         loadMessagesListUseCase: loadMessagesListUseCase,
                         streamMessageEventsUseCase: streamMessageEventsUseCase,
                         sendMessageUseCase: sendMessageUseCase)
  }
  
  func makeLoadMessagesListUseCase() -> LoadMessagesListUseCaseProtocol {
    return LoadMessagesListUseCase(remoteAPI: sharedMessagesRemoteAPI)
  }
  
  func makeStreamMessageEventsUseCase() -> StreamMessageEventsUseCaseProtocol {
    return StreamMessageEventsUseCase(remoteAPI: sharedMessagesRemoteAPI)
  }
  
  func makeSendMessageUseCase() -> SendMessageUseCaseProtocol {
    return SendMessageUseCase(remoteAPI: sharedMessagesRemoteAPI)
  }
}

// MARK: - SettingsViewFactory
extension SignedInDependencyContainer: SettingsViewFactory {
  
  func makeSettingsView() -> SettingsView {
    let viewModel = makeSettingsViewModel()
    return SettingsView(viewModel: viewModel)
  }
  
  func makeSettingsViewModel() -> SettingsViewModel {
    let useCase = makeLogoutUseCase()
    return SettingsViewModel(logoutUseCase: useCase,
                             notSignedInResponder: sharedMainViewModel)
  }
  
  func makeLogoutUseCase() -> LogoutUseCaseProtocol {
    return LogoutUseCase(dataStore: sharedUserSessionDataStore)
  }
}
