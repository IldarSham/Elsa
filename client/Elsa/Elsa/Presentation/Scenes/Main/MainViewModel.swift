//
//  MainViewModel.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 14.12.2024.
//

import Combine

final class MainViewModel: ObservableObject, SignedInResponder, NotSignedInResponder {
  
  @Published public var state: MainViewState = .launching
  
  public func notSignedIn() {
    self.state = .notSignedIn
  }
  
  public func signedIn(to userSession: RemoteUserSession) {
    self.state = .signedIn(userSession: userSession)
  }
}
