//
//  LoginView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 01.11.2024.
//

import SwiftUI

struct LoginView: View {
  
  private enum Field: Hashable {
    case email
    case password
  }
  
  @FocusState private var focusedField: Field?
  
  @ObservedObject var viewModel: LoginViewModel
  let registerViewFactory: RegisterViewFactory
  
  var body: some View {
    NavigationView {
      VStack {
        Image("logo")
          .resizable()
          .frame(width: 112, height: 123)
        
        Spacer().frame(height: 30)
        
        VStack(spacing: 20) {
          MaterialDesignTextField(.standard, placeholder: "E-mail", text: $viewModel.email, isInvalid: $viewModel.isEmailInvalid)
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
              focusedField = .password
            }
          
          MaterialDesignTextField(.secure, placeholder: "Пароль*", text: $viewModel.password, isInvalid: $viewModel.isPasswordInvalid)
            .focused($focusedField, equals: .password)
            .submitLabel(.done)
        }
        .padding(.horizontal, 25)
        
        PrimaryButton("Войти", action: viewModel.login, isLoading: $viewModel.isLoading)
          .padding(.horizontal, 25)
          .padding(.top, 10)
          .padding(.bottom, 25)
        
        Text("У вас нет учетной записи?")
        
        NavigationLink(destination: registerViewFactory.makeRegisterView()) {
          Text("Зарегистрироваться")
            .fontWeight(.semibold)
            .foregroundStyle(Color.primaryBlue)
        }
      }
      .alert("Ошибка", isPresented: $viewModel.isDisplayingError, actions: {
        Button("Закрыть", role: .cancel) { }
      }, message: {
        Text(viewModel.lastErrorMessage)
      })
      .frame(maxHeight: .infinity)
      .ignoresSafeArea()
    }
  }
}

@MainActor
protocol LoginViewFactory {
  func makeLoginView() -> LoginView
}

#Preview {
  let injectionContainer = AppDependencyContainer()
  injectionContainer.makeLoginView()
}
