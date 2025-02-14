//
//  MessageView.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 04.12.2024.
//

import SwiftUI

struct MessageView: View {
  let viewModel: MessageViewModel
  
  var body: some View {
    HStack(alignment: .top, spacing: 15) {
      if !viewModel.sentByMe {
        Image("logo2")
          .resizable()
          .frame(width: 17, height: 18)
          .padding(8)
          .overlay(
            Circle().stroke(Color(UIColor.systemGray5), lineWidth: 1)
          )
      } else {
        Spacer()
      }
      
      Text(viewModel.text)
        .padding(10)
        .foregroundColor(viewModel.sentByMe ? .black : .white)
        .background(viewModel.sentByMe ? Color(UIColor.systemGray6) : Color.primaryBlue)
        .cornerRadius(10)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal)
  }
}

#Preview {
  let viewModel = MessageViewModel(text: "Hello, world!", sentByMe: true)
  MessageView(viewModel: viewModel)
}
