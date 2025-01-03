//
//  RegisterView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 20.11.2024.
//

import SwiftUI

struct RegisterView: View {
  
  private enum Field: Hashable {
    case firstName
    case lastName
    case email
    case password
  }
  
  @Environment(\.dismiss) private var dismiss
  @FocusState private var focusedField: Field?
  
  @ObservedObject var viewModel: RegisterViewModel
  
  var body: some View {
    VStack {
      Text("Создать\nучетную запись")
        .font(.system(size: 30, weight: .bold))
        .lineSpacing(3)
        .multilineTextAlignment(.center)
      
      Spacer().frame(height: 30)
      
      VStack(spacing: 20) {
        HStack(spacing: 20) {
          MaterialDesignTextField(placeholder: "Имя", text: $viewModel.firstName, isInvalid: $viewModel.isFirstNameInvalid)
            .focused($focusedField, equals: .firstName)
            .submitLabel(.next)
            .onSubmit {
              focusedField = .lastName
            }
          
          MaterialDesignTextField(placeholder: "Фамилия", text: $viewModel.lastName, isInvalid: $viewModel.isLastNameInvalid)
            .focused($focusedField, equals: .lastName)
            .submitLabel(.next)
            .onSubmit {
              focusedField = .email
            }
        }
        
        MaterialDesignTextField(placeholder: "E-mail", text: $viewModel.email, isInvalid: $viewModel.isEmailInvalid)
          .focused($focusedField, equals: .email)
          .submitLabel(.next)
          .onSubmit {
            focusedField = .password
          }
        
        MaterialDesignTextField(.secure, placeholder: "Пароль", text: $viewModel.password, isInvalid: $viewModel.isPasswordInvalid)
          .focused($focusedField, equals: .password)
          .submitLabel(.done)
      }
      .padding(.horizontal, 25)
      
      PrimaryButton("Зарегистрироваться", action: viewModel.register, isLoading: $viewModel.isLoading)
        .padding(.horizontal, 25)
        .padding(.top, 10)
        .padding(.bottom, 25)
      
      HStack {
        Text("У вас уже есть учетная запись?")
        Button(action: { dismiss() }) {
          Text("Войти")
            .fontWeight(.semibold)
            .foregroundStyle(Color.primaryBlue)
        }
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

@MainActor
protocol RegisterViewFactory {
  func makeRegisterView() -> RegisterView
}

#Preview {
  let injectionContainer = AppDependencyContainer()
  injectionContainer.makeRegisterView()
}
