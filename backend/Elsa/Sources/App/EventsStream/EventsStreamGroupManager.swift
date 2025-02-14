//
//  EventsStreamGroupManager.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 28.12.2024.
//

import Foundation

public actor EventsStreamGroupManager<Event: StreamableEvent> {
  
  // MARK: - Properties
  private var streams: [UUID: EventsStreamManager<Event>] = [:]
  
  // MARK: - Public Methods
  public func create(for id: UUID) async -> EventsStreamManager<Event> {
    if let existing = streams[id] {
      await existing.terminate()
    }
    
    let manager = await EventsStreamManager<Event> { [weak self] in
      await self?.remove(for: id)
    }
    streams[id] = manager
    return manager
  }
  
  public func get(for id: UUID) -> EventsStreamManager<Event>? {
    streams[id]
  }
  
  public func terminate(for id: UUID) async {
    if let manager = streams[id] {
      await manager.terminate()
      await remove(for: id)
    }
  }
  
  // MARK: - Private Methods
  private func remove(for id: UUID) async {
    if let manager = streams[id], await manager.isTerminated {
      streams[id] = nil
    }
  }
}
