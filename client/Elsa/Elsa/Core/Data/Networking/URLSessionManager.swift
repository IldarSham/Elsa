//
//  URLSessionManager.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 15.12.2024.
//

import Foundation

protocol URLSessionManagerProtocol {
  func performRequest(_ urlRequest: URLRequest) async throws -> Data
  func performLiveRequest(_ urlRequest: URLRequest) async throws -> URLSession.AsyncBytes
}

final class URLSessionManager: URLSessionManagerProtocol {
  
  // MARK: - Properties
  
  private let urlSession: URLSession
  
  private lazy var liveURLSession: URLSession = {
    var configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = .infinity
    return URLSession(configuration: configuration)
  }()
  
  // MARK: - Initialization
  
  init(urlSession: URLSession = .shared) {
    self.urlSession = urlSession
  }
  
  // MARK: - Public Methods
  
  func performRequest(_ urlRequest: URLRequest) async throws -> Data {
    let (data, response) = try await urlSession.data(for: urlRequest)
    try handleServerResponse(response)
    return data
  }
  
  func performLiveRequest(_ urlRequest: URLRequest) async throws -> URLSession.AsyncBytes {
    let (stream, response) = try await liveURLSession.bytes(for: urlRequest)
    try handleServerResponse(response)
    return stream
  }
  
  // MARK: - Private Methods
  
  private func handleServerResponse(_ response: URLResponse) throws {
    if let httpResponse = response as? HTTPURLResponse,
       httpResponse.statusCode != 200 {
      throw NetworkError.invalidServerResponse(statusCode: httpResponse.statusCode)
    }
  }
}

enum NetworkError: Error {
  case invalidServerResponse(statusCode: Int)
}
