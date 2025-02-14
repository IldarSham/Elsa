//
//  ProfileView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 22.12.2024.
//

import SwiftUI

struct ProfileView: View {
  
  // MARK: - Properties
  @ObservedObject var viewModel: ProfileViewModel
  
  // MARK: - Body
  var body: some View {
    NavigationView {
      List {
        Button(role: .destructive) {
          viewModel.logout()
        } label: {
          Text("Выход")
        }
      }
      .listStyle(.grouped)
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Профиль")
    }
    .alert("Ошибка", isPresented: $viewModel.isDisplayingError, actions: {
      Button("Закрыть", role: .cancel) { }
    }, message: {
      Text(viewModel.lastErrorMessage)
    })
  }
}

@MainActor
protocol ProfileViewFactory {
  func makeProfileView() -> ProfileView
}
