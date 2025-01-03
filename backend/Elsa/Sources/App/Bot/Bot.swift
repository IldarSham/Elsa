//
//  Bot.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 23.12.2024.
//

import Foundation

final class Bot: @unchecked Sendable {
  
  // MARK: - Properties
  private var commands: [BotCommand] = []
  
  // MARK: - Initialization
  init() {
    registerCommand(PingCommand())
  }
  
  // MARK: - Public Methods
  public func getResponse(to input: String) async -> String {
    for command in commands {
      if await input == command.pattern {
        return await command.execute(with: input)
      }
    }
    
    return "Извините, я не понимаю ваш запрос."
  }
  
  // MARK: - Private Methods
  private func registerCommand(_ command: BotCommand) {
    commands.append(command)
  }
}
