//
//  SSEHub.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 28.12.2024.
//

import Foundation

public actor SSEHub<ID, Event> where ID: Hashable & Sendable, Event: StreamableEvent {
  
  // MARK: - Types
  
  private struct ClientConnection {
    let continuation: AsyncStream<Event>.Continuation
    let keepAliveTask: Task<Void, Never>
    
    func terminate() {
      keepAliveTask.cancel()
      continuation.finish()
    }
  }
  
  private var connections: [ID: ClientConnection] = [:]
  private let keepAliveInterval: Duration
  
  // MARK: - Initialization
  
  public init(keepAliveInterval: Duration = .seconds(20)) {
    self.keepAliveInterval = keepAliveInterval
  }
  
  // MARK: - Public Methods
  
  public func subscribe(for id: ID) -> SSEStream<Event> {
    if let existingChannel = connections[id] {
      existingChannel.terminate()
    }
    
    let (stream, continuation) = AsyncStream.makeStream(of: Event.self)
    let keepAliveTask = createKeepAliveTask(for: continuation)
    
    connections[id] = ClientConnection(
      continuation: continuation,
      keepAliveTask: keepAliveTask
    )
            
    return SSEStream(
      stream: stream,
      errorHandler: { [weak self] in
        await self?.unsubscribe(for: id)
      }
    )
  }
  
  public func send(_ event: Event, to id: ID) {
    connections[id]?.continuation.yield(event)
  }
  
  public func unsubscribe(for id: ID) {
    connections.removeValue(forKey: id)?.terminate()
  }
  
  // MARK: - Private Methods
  
  private func createKeepAliveTask(
    for continuation: AsyncStream<Event>.Continuation
  ) -> Task<Void, Never> {
    Task {
      while !Task.isCancelled {
        do {
          try await Task.sleep(for: keepAliveInterval)
          continuation.yield(Event.emptyEvent())
        } catch {
          break
        }
      }
    }
  }
}
