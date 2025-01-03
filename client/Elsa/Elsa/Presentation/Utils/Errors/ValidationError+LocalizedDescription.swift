//
//  ValidationError+LocalizedDescription.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 02.01.2025.
//

import Foundation

extension ValidationError: LocalizedError {
  
  var errorDescription: String? {
    switch self {
    case .emailIsEmpty:
      return "Пожалуйста, введите адрес электронной почты."
    case .passwordIsEmpty:
      return "Пожалуйста, введите пароль."
    case .invalidEmailFormat:
      return "Неверный формат адреса электронной почты. Пожалуйста, проверьте правильность ввода."
    case .invalidPasswordLength:
      return "Пароль должен содержать не менее 8 символов."
    case .firstNameIsEmpty:
      return "Пожалуйста, введите имя пользователя."
    case .lastNameIsEmpty:
      return "Пожалуйста, введите фамилию пользователя."
    }
  }
}
