//
//  RegisterViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 13.12.2024.
//

import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
  
  // MARK: - Published Properties
  @Published public var firstName: String = ""
  @Published public var lastName: String = ""
  @Published public var email: String = ""
  @Published public var password: String = ""
  
  @Published public var isLoading: Bool = false
  @Published public var lastErrorMessage = "" {
    didSet {
      isDisplayingError = true
    }
  }
  @Published public var isDisplayingError = false
  
  @Published public var isFirstNameInvalid = false
  @Published public var isLastNameInvalid = false
  @Published public var isEmailInvalid = false
  @Published public var isPasswordInvalid = false

  // MARK: - Private Properties
  private let registerUseCase: RegisterUseCaseProtocol
  private let signedInResponder: SignedInResponder
  
  // MARK: - Initialization
  public init(registerUseCase: RegisterUseCaseProtocol,
              signedInResponder: SignedInResponder) {
    self.registerUseCase = registerUseCase
    self.signedInResponder = signedInResponder
  }
  
  // MARK: - Public Methods
  public func register() {
    guard validateInputs() else { return }
    
    let newAccount = NewAccountPayload(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password)
    
    Task {
      isLoading = true
      defer { isLoading = false }
      
      do {
        let session = try await registerUseCase.register(newAccount: newAccount)
        onRegisterSuccess(userSession: session)
      } catch {
        onRegisterFailure(error: error)
      }
    }
  }
  
  // MARK: - Private Methods
  private func onRegisterSuccess(userSession: RemoteUserSession) {
    signedInResponder.signedIn(to: userSession)
  }
  
  private func onRegisterFailure(error: Error) {
    lastErrorMessage = error.localizedDescription
  }
  
  private func validateInputs() -> Bool {
    isFirstNameInvalid = validateField { try Validator.validateFirstName(firstName) }
    isLastNameInvalid = validateField { try Validator.validateLastName(lastName) }
    isEmailInvalid = validateField { try Validator.validateEmail(email) }
    isPasswordInvalid = validateField { try Validator.validatePassword(password) }
    return !isFirstNameInvalid && !isLastNameInvalid
      && !isEmailInvalid && !isPasswordInvalid
  }
  
  private func validateField(validator: () throws -> Void) -> Bool {
    return hasValidationError(validator: validator,
                              onError: handleValidationError)
  }
  
  private func handleValidationError(_ error: Error) {
    lastErrorMessage = error.localizedDescription
  }
}
