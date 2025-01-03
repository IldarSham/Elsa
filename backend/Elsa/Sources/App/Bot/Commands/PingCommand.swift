//
//  PingCommand.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 23.12.2024.
//

import Foundation

actor PingCommand: BotCommand {
  
  nonisolated var pattern: String {
    "/ping"
  }
  
  nonisolated func execute(with input: String) -> String {
    "pong"
  }
}
