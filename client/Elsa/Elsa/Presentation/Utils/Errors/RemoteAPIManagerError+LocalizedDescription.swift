//
//  RemoteAPIManagerError+LocalizedDescription.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 02.01.2025.
//

import Foundation

extension RemoteAPIManagerError: LocalizedError {
  
  var errorDescription: String? {
    switch self {
    case .unauthorized:
      return "Не удалось авторизоваться. Проверьте корректность введеных данных."
    default:
      return nil
    }
  }
}
