//
//  ValidatorHelper.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 02.01.2025.
//

import Foundation

public func hasValidationError(validator: () throws -> Void, onError: (Error) -> Void) -> Bool {
  do {
    try validator()
    return false
  } catch {
    onError(error)
    return true
  }
}
