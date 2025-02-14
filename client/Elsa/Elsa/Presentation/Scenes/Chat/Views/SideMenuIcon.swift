//
//  SideMenuIcon.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 28.01.2025.
//

import SwiftUI

struct SideMenuIcon: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 7) {
      Capsule()
        .frame(width: 16, height: 2)
      Capsule()
        .frame(width: 12, height: 2)
    }
    .tint(Color.black)
  }
}
