//
//  EventsStreamManager.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 28.12.2024.
//

import Foundation

public actor EventsStreamManager<Event: StreamableEvent> {
  
  // MARK: - Properties
  private let stream: AsyncStream<Event>
  private let continuation: AsyncStream<Event>.Continuation
  
  private var keepAliveTask: Task<Void, Never>?
  private let keepAliveInterval: Duration
  
  private(set) var isTerminated = false
  private let onTermination: @Sendable () async -> Void
  
  // MARK: - Initialization
  public init(
    keepAliveInterval: Duration = .seconds(300),
    onTermination: @escaping @Sendable () async -> Void
  ) async {
    self.keepAliveInterval = keepAliveInterval
    self.onTermination = onTermination
    
    let (stream, continuation) = AsyncStream.makeStream(of: Event.self)
    self.stream = stream
    self.continuation = continuation
    self.continuation.onTermination = { _ in
      Task { await onTermination() }
    }
    
    startKeepAlive()
  }
  
  // MARK: - Public Methods
  public func send(_ event: Event) {
    continuation.yield(event)
  }
  
  public func createEventsStream() -> EventsStream<Event> {
    EventsStream(
      stream: stream,
      errorHandler: { [weak self] in
        await self?.terminate()
      }
    )
  }
  
  public func terminate() async {
    guard !isTerminated else { return }
    isTerminated = true
    keepAliveTask?.cancel()
    continuation.finish()
  }
  
  // MARK: - Private Methods
  private func startKeepAlive() {
    keepAliveTask = Task {
      while !Task.isCancelled {
        try? await Task.sleep(for: keepAliveInterval)
        continuation.yield(Event.emptyEvent())
      }
    }
  }
}
