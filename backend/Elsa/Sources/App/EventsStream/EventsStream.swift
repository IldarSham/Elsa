//
//  EventsStream.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 28.12.2024.
//

import Vapor

public protocol StreamableEvent: Encodable, Sendable {
  static func emptyEvent() -> Self
}

public struct EventsStream<Event: StreamableEvent>: AsyncResponseEncodable, Sendable {
  
  // MARK: - Properties
  private let stream: AsyncStream<Event>
  private let errorHandler: @Sendable () async -> Void
  
  private let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()
  
  // MARK: - Initialization
  public init(stream: AsyncStream<Event>,
              errorHandler: @escaping @Sendable () async -> Void) {
    self.stream = stream
    self.errorHandler = errorHandler
  }
  
  // MARK: - Methods
  public func encodeResponse(for request: Request) async throws -> Response {
    let response = Response(body: .init(asyncStream: { writer in
      for try await item in stream {
        do {
          let data = try jsonEncoder.encode(item) + "\r\n".data(using: .utf8)!
          try await writer.write(.buffer(.init(data: data)))
        } catch {
          await errorHandler()
          try await writer.write(.error(error))
        }
      }
      try await writer.write(.end)
    }))
    
    response.headers.add(name: .contentType, value: "application/octet-stream")
    return response
  }
}
