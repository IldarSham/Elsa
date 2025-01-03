//
//  LaunchView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 21.12.2024.
//

import SwiftUI

struct LaunchView: View {
  let viewModel: LaunchViewModel
  
  var body: some View {
    ProgressView().onAppear {
      viewModel.onAppear()
    }
  }
}

@MainActor
protocol LaunchViewFactory {
  func makeLaunchView() -> LaunchView
}
