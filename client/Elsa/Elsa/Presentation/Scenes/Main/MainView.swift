//
//  MainView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 14.12.2024.
//

import SwiftUI

struct MainView: View {
  
  @ObservedObject var viewModel: MainViewModel
  
  // Factories
  let launchViewFactory: LaunchViewFactory
  let loginViewFactory: LoginViewFactory
  let signedInViewFactory: SignedInViewFactory
  
  init(
    viewModel: MainViewModel,
    launchViewFactory: LaunchViewFactory,
    loginViewFactory: LoginViewFactory,
    signedInViewFactory: SignedInViewFactory
  ) {
    self.viewModel = viewModel
    self.launchViewFactory = launchViewFactory
    self.loginViewFactory = loginViewFactory
    self.signedInViewFactory = signedInViewFactory
  }

  var body: some View {
    ZStack {
      switch viewModel.state {
      case .launching:
        launchViewFactory.makeLaunchView()
          .transition(.opacity)
      case .notSignedIn:
        loginViewFactory.makeLoginView()
          .transition(.opacity)
      case .signedIn(let userSession):
        signedInViewFactory.makeSignedInView(userSession: userSession)
          .transition(.scale)
      }
    }
    .animation(.easeInOut, value: viewModel.state)
  }
}
