//
//  LaunchViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 21.12.2024.
//

import Foundation

final class LaunchViewModel {
  
  // MARK: - Private Properties
  private let loadUserSessionUseCase: LoadUserSessionUseCaseProtocol
  private let notSignedInResponder: NotSignedInResponder
  private let signedInResponder: SignedInResponder
  
  // MARK: - Initialization
  public init(loadUserSessionUseCase: LoadUserSessionUseCaseProtocol,
              notSignedInResponder: NotSignedInResponder,
              signedInResponder: SignedInResponder) {
    self.loadUserSessionUseCase = loadUserSessionUseCase
    self.notSignedInResponder = notSignedInResponder
    self.signedInResponder = signedInResponder
  }
  
  // MARK: - Public Methods
  public func onAppear() {
    do {
      try loadUserSession()
    } catch {
      print(error)
    }
  }
  
  // MARK: - Private Methods
  private func loadUserSession() throws {
    let userSession = try loadUserSessionUseCase.load()
    switch userSession {
    case .some(let userSession):
      signedInResponder.signedIn(to: userSession)
    case .none:
      notSignedInResponder.notSignedIn()
    }
  }
}
