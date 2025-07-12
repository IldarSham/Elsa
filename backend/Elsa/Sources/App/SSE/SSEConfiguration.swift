//
//  SSEConfiguration.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 12.07.2025.
//

import Vapor

public struct SSEConfiguration: Sendable {
  
  // MARK: - Properties
  
  public let encoder: JSONEncoder
  public let headers: HTTPHeaders
  
  // MARK: - Initialization
  
  public init(encoder: JSONEncoder, headers: HTTPHeaders) {
    self.encoder = encoder
    self.headers = headers
  }
  
  // MARK: - Default Configuration
  
  public static let `default` = SSEConfiguration(
    encoder: Self.createDefaultEncoder(),
    headers: Self.createDefaultHeaders()
  )
  
  private static func createDefaultEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }
  
  private static func createDefaultHeaders() -> HTTPHeaders {
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "text/event-stream")
    headers.add(name: .cacheControl, value: "no-cache")
    headers.add(name: .connection, value: "keep-alive")
    headers.add(name: .accessControlAllowOrigin, value: "*")
    return headers
  }
}
