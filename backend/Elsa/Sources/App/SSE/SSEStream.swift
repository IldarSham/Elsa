//
//  SSEStream.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 28.12.2024.
//

import Vapor

public protocol StreamableEvent: Encodable, Sendable {
  static func emptyEvent() -> Self
}

public struct SSEStream<Event: StreamableEvent>: AsyncResponseEncodable, Sendable {
  
  // MARK: - Type Aliases
  
  public typealias ErrorHandler = @Sendable () async -> Void
  
  // MARK: - Properties
  
  private let eventStream: AsyncStream<Event>
  private let onError: ErrorHandler
  private let streamConfiguration: SSEConfiguration
  
  // MARK: - Initialization
  
  public init(
    stream: AsyncStream<Event>,
    errorHandler: @escaping ErrorHandler,
    configuration: SSEConfiguration = .default
  ) {
    self.eventStream = stream
    self.onError = errorHandler
    self.streamConfiguration = configuration
  }
  
  // MARK: - AsyncResponseEncodable
  
  public func encodeResponse(for request: Request) async throws -> Response {
    let streamingBody = Response.Body(asyncStream: { writer in
      try await self.streamEvents(to: writer)
    })
    
    return Response(
      status: .ok,
      headers: streamConfiguration.headers,
      body: streamingBody
    )
  }
  
  // MARK: - Private Methods
  
  private func streamEvents(to writer: AsyncBodyStreamWriter) async throws {
    do {
      for try await event in eventStream {
        try await writeEvent(event, to: writer)
      }
    } catch {
      await handleStreamError(error, writer: writer)
    }
    
    try await finalizeStream(writer)
  }
  
  private func writeEvent(_ event: Event, to writer: AsyncBodyStreamWriter) async throws {
    let eventData = try streamConfiguration.encoder.encode(event)
    let formattedData = eventData + Data("\r\n".utf8)
    try await writer.write(.buffer(.init(data: formattedData)))
  }
  
  private func handleStreamError(_ error: Error, writer: AsyncBodyStreamWriter) async {
    await onError()
    try? await writer.write(.error(error))
  }
  
  private func finalizeStream(_ writer: AsyncBodyStreamWriter) async throws {
    try await writer.write(.end)
  }
}
