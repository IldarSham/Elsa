//
//  MessageTextField.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 09.12.2024.
//

import SwiftUI

struct MessageTextField: View {
  
  let placeholder: String
  @Binding var text: String
  
  @FocusState private var isFocused: Bool
  
  var body: some View {
    ZStack(alignment: .leading) {
      TextField("", text: $text, axis: .vertical)
        .lineLimit(8)
        .focused($isFocused)
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(Color(red: 242/255, green: 242/255, blue: 245/255))
        .cornerRadius(25)
      
      if text.isEmpty {
        Text(placeholder)
          .foregroundStyle(Color(red: 145/255, green: 156/255, blue: 181/255))
          .padding(.horizontal, 20)
      }
    }
    .onTapGesture {
      isFocused = true
    }
  }
}
