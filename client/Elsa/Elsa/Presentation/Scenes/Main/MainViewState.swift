//
//  MainViewState.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 21.12.2024.
//

import Foundation

enum MainViewState: Equatable {
  case launching
  case notSignedIn
  case signedIn(userSession: RemoteUserSession)
  
  public static func == (lhs: MainViewState, rhs: MainViewState) -> Bool {
    switch (lhs, rhs) {
    case (.launching, .launching):
      return true
      case (.notSignedIn, .notSignedIn):
      return true
    case (.signedIn(let lhsUserSession), .signedIn(let rhsUserSession)):
      return lhsUserSession.token == rhsUserSession.token
    default:
      return false
    }
  }
}
