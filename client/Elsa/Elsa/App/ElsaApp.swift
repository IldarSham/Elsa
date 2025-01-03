//
//  ElsaApp.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 01.11.2024.
//

import SwiftUI

@main
struct ElsaApp: App {
  let injectionContainer = AppDependencyContainer()
  
  var body: some Scene {
    WindowGroup {
      injectionContainer.makeMainView()
    }
  }
}
