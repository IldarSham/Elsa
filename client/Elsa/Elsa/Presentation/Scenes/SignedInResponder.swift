//
//  SignedInResponder.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 21.12.2024.
//

import Foundation

protocol SignedInResponder {
  func signedIn(to userSession: RemoteUserSession)
}
