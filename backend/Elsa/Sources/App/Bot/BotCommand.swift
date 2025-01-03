//
//  BotCommand.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 23.12.2024.
//

import Foundation

protocol BotCommand: Sendable {
  var pattern: String { get async }
  
  func execute(with input: String) async -> String
}
