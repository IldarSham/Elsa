//
//  Validator.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 02.01.2025.
//

import Foundation

struct Validator {
  
  enum Constants {
    static let passwordRequiredLength = 6
  }
  
  static func validateEmail(_ email: String) throws {
    guard !email.isEmpty else {
      throw ValidationError.emailIsEmpty
    }
    
    guard email.contains(#/^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/#) else {
      throw ValidationError.invalidEmailFormat
    }
  }
  
  static func validatePassword(_ password: String) throws {
    guard !password.isEmpty else {
      throw ValidationError.passwordIsEmpty
    }
    
    guard password.count >= Constants.passwordRequiredLength else {
      throw ValidationError.invalidPasswordLength
    }
  }
  
  static func validateFirstName(_ firstName: String) throws {
    guard !firstName.isEmpty else {
      throw ValidationError.firstNameIsEmpty
    }
  }
  
  static func validateLastName(_ lastName: String) throws {
    guard !lastName.isEmpty else {
      throw ValidationError.lastNameIsEmpty
    }
  }
}

enum ValidationError: Error {
  case emailIsEmpty
  case passwordIsEmpty
  case invalidEmailFormat
  case invalidPasswordLength
  case firstNameIsEmpty
  case lastNameIsEmpty
}
