//
//  AppDependencyContainer.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 15.12.2024.
//

import Foundation

@MainActor
final class AppDependencyContainer {
  
  // Long-lived dependencies
  let sharedUserSessionDataStore: UserSessionDataStoreProtocol
  let sharedMainViewModel: MainViewModel
  let sharedRemoteAPIManager: RemoteAPIManagerProtocol
  
  init() {
    func makeUserSessionDataStore() -> UserSessionDataStoreProtocol {
      let userSessionCoding: UserSessionCoding = UserSessionPropertyListCoder()
      return UserSessionDataStore(userSessionCoder: userSessionCoding)
    }
    func makeMainViewModel() -> MainViewModel {
      return MainViewModel()
    }
    func makeUrlSessionManager() -> URLSessionManagerProtocol {
      return URLSessionManager()
    }
    func makeRemoteAPIManager() -> RemoteAPIManagerProtocol {
      let urlSessionManager = makeUrlSessionManager()
      return RemoteAPIManager(urlSessionManager: urlSessionManager)
    }
    
    self.sharedUserSessionDataStore =  makeUserSessionDataStore()
    self.sharedMainViewModel = makeMainViewModel()
    self.sharedRemoteAPIManager = makeRemoteAPIManager()
  }

  public func makeMainView() -> MainView {
    return MainView(viewModel: sharedMainViewModel,
                    launchViewFactory: self,
                    loginViewFactory: self,
                    signedInViewFactory: self)
  }
  
  public func makeLoadUserSessionUseCase() -> LoadUserSessionUseCaseProtocol {
    return LoadUserSessionUseCase(dataStore: sharedUserSessionDataStore)
  }
  
  public func makeAuthRemoteAPI() -> AuthRemoteAPIProtocol {
    return AuthRemoteAPI(apiManager: sharedRemoteAPIManager)
  }
}

// MARK: - LaunchViewFactory
extension AppDependencyContainer: LaunchViewFactory {
  
  public func makeLaunchView() -> LaunchView {
    let viewModel = makeLaunchViewModel()
    return LaunchView(viewModel: viewModel)
  }
  
  public func makeLaunchViewModel() -> LaunchViewModel {
    let useCase = makeLoadUserSessionUseCase()
    return LaunchViewModel(loadUserSessionUseCase: useCase,
                           notSignedInResponder: sharedMainViewModel,
                           signedInResponder: sharedMainViewModel)
  }
}
 
// MARK: - LoginViewFactory
extension AppDependencyContainer: LoginViewFactory {
  
  public func makeLoginView() -> LoginView {
    let viewModel = makeLoginViewModel()
    return LoginView(viewModel: viewModel,
                     registerViewFactory: self)
  }
  
  public func makeLoginViewModel() -> LoginViewModel {
    let useCase = makeLoginUseCase()
    return LoginViewModel(loginUseCase: useCase,
                          signedInResponder: sharedMainViewModel)
  }
  
  public func makeLoginUseCase() -> LoginUseCaseProtocol {
    let remoteAPI = makeAuthRemoteAPI()
    return LoginUseCase(remoteAPI: remoteAPI,
                        dataStore: sharedUserSessionDataStore)
  }
}

// MARK: - RegisterViewFactory
extension AppDependencyContainer: RegisterViewFactory {
  
  public func makeRegisterView() -> RegisterView {
    let viewModel = makeRegisterViewModel()
    return RegisterView(viewModel: viewModel)
  }
  
  public func makeRegisterViewModel() -> RegisterViewModel {
    let useCase = makeRegisterUseCase()
    return RegisterViewModel(registerUseCase: useCase,
                             signedInResponder: sharedMainViewModel)
  }
  
  public func makeRegisterUseCase() -> RegisterUseCaseProtocol {
    let remoteAPI = makeAuthRemoteAPI()
    return RegisterUseCase(remoteAPI: remoteAPI,
                           dataStore: sharedUserSessionDataStore)
  }
}

// MARK: - SignedInViewFactory
extension AppDependencyContainer: SignedInViewFactory {
  
  public func makeSignedInView(userSession: RemoteUserSession) -> SignedInView {
    let dependencyContainer = SignedInDependencyContainer(userSession: userSession,
                                                          appDependencyContainer: self)
    return dependencyContainer.makeSignedInView()
  }
}
