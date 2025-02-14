//
//  LoginViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 13.12.2024.
//

import Combine

@MainActor
final class LoginViewModel: ObservableObject {
  
  // MARK: - Published Properties
  @Published public var email: String = ""
  @Published public var password: String = ""
  
  @Published public var isEmailInvalid = false
  @Published public var isPasswordInvalid = false
  
  @Published public var isLoading: Bool = false
  
  @Published public var lastErrorMessage = "" {
    didSet { isDisplayingError = true }
  }
  @Published public var isDisplayingError = false
    
  // MARK: - Dependencies
  private let loginUseCase: LoginUseCaseProtocol
  private let signedInResponder: SignedInResponder
  
  // MARK: - Initialization
  public init(loginUseCase: LoginUseCaseProtocol,
              signedInResponder: SignedInResponder) {
    self.loginUseCase = loginUseCase
    self.signedInResponder = signedInResponder
  }
  
  // MARK: - Public Methods
  public func login() {
    guard validateInputs() else { return }
    
    Task {
      isLoading = true
      defer { isLoading = false }
      
      do {
        let session = try await loginUseCase.login(email: email, password: password)
        onLoginSuccess(userSession: session)
      } catch {
        onLoginFailure(error: error)
      }
    }
  }
  
  // MARK: - Private Methods
  
  private func onLoginSuccess(userSession: RemoteUserSession) {
    signedInResponder.signedIn(to: userSession)
  }
  
  private func onLoginFailure(error: Error) {
    lastErrorMessage = error.localizedDescription
  }
  
  private func validateInputs() -> Bool {
    isEmailInvalid = validateField { try Validator.validateEmail(email) }
    isPasswordInvalid = validateField { try Validator.validatePassword(password) }
    return !isEmailInvalid && !isPasswordInvalid
  }
  
  private func validateField(validator: () throws -> Void) -> Bool {
    return hasValidationError(validator: validator, onError: handleValidationError)
  }
  
  private func handleValidationError(_ error: Error) {
    lastErrorMessage = error.localizedDescription
  }
}
