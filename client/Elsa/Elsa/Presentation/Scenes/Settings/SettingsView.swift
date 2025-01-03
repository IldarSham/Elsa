//
//  SettingsView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 22.12.2024.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel
  
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
      .navigationTitle("Настройки")
    }
    .alert("Ошибка", isPresented: $viewModel.isDisplayingError, actions: {
      Button("Закрыть", role: .cancel) { }
    }, message: {
      Text(viewModel.lastErrorMessage)
    })
  }
}

@MainActor
protocol SettingsViewFactory {
  func makeSettingsView() -> SettingsView
}
