//
//  SettingsViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 22.12.2024.
//

import Foundation

final class SettingsViewModel: ObservableObject {
  
  // MARK: - Published Properties
  @Published public var isDisplayingError = false
  @Published public var lastErrorMessage = "" {
    didSet {
      isDisplayingError = true
    }
  }
  
  // MARK: - Private Properties
  private let logoutUseCase: LogoutUseCaseProtocol
  private let notSignedInResponder: NotSignedInResponder
  
  // MARK: - Initialization
  public init(logoutUseCase: LogoutUseCaseProtocol,
              notSignedInResponder: NotSignedInResponder) {
    self.logoutUseCase = logoutUseCase
    self.notSignedInResponder = notSignedInResponder
  }
  
  // MARK: - Public Methods
  public func logout() {
    do {
      try logoutUseCase.logout()
      notSignedInResponder.notSignedIn()
    } catch {
      lastErrorMessage = error.localizedDescription
    }
  }
}
