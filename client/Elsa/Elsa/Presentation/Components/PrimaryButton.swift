//
//  PrimaryButton.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 26.12.2024.
//

import SwiftUI

public struct PrimaryButton: View {
  private let title: String
  private let action: () -> Void
  @Binding private var isLoading: Bool
  
  public init(_ title: String,
              action: @escaping () -> Void,
              isLoading: Binding<Bool>) {
    self.title = title
    self.action = action
    self._isLoading = isLoading
  }
  
  public var body: some View {
    Button(action: action) {
      if !isLoading {
        Text(title)
          .font(.headline)
          .foregroundStyle(.white)
      } else {
        ProgressView()
          .tint(.white)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 15)
    .background(
      .linearGradient(
        colors: [
          Color(red: 20/255, green: 166/255, blue: 201/255),
          Color(red: 189/255, green: 230/255, blue: 240/255)
        ],
        startPoint: .leading,
        endPoint: .trailing
      ))
    .cornerRadius(10)
    .disabled(isLoading)
  }
}
