//
//  RemoteAPIManager.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 15.12.2024.
//

import Foundation

final class RemoteAPIManager: RemoteAPIManagerProtocol {
  
  // MARK: - Properties
  
  private let baseURL = "http://localhost:8080"
  
  private let urlSessionManager: URLSessionManagerProtocol
  
  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()
  
  // MARK: - Initialization
  
  init(urlSessionManager: URLSessionManagerProtocol) {
    self.urlSessionManager = urlSessionManager
  }
  
  // MARK: Public Methods
  
  func callAPI<T: Decodable>(
    with data: RequestProtocol,
    authToken: String?
  ) async throws -> T {
    let urlRequest = try makeRequest(with: data, authToken: authToken)
    
    do {
      let data = try await urlSessionManager.performRequest(urlRequest)
      return try decoder.decode(T.self, from: data)
    } catch let error as NetworkError {
      if case .invalidServerResponse(statusCode: 401) = error {
        throw RemoteAPIManagerError.unauthorized
      } else {
        throw error
      }
    }
  }
  
  func callAPI<T: Decodable>(
    with data: LiveRequestProtocol,
    authToken: String?
  ) async throws -> AsyncStream<T> {
    let urlRequest = try makeRequest(with: data, authToken: authToken)
    
    do {
      let stream = try await urlSessionManager.performLiveRequest(urlRequest)

      return AsyncStream<T> { continuation in
        Task {
          for try await line in stream.lines {
            if let data = line.data(using: .utf8),
              let update = try? decoder.decode(T.self, from: data) {
              continuation.yield(update)
            }
          }
        }
      }
    } catch let error as NetworkError {
      if case .invalidServerResponse(statusCode: 401) = error {
        throw RemoteAPIManagerError.unauthorized
      } else {
        throw error
      }
    }
  }
  
  // MARK: - Private Methods
  
  private func makeRequest(
    with data: RequestProtocol,
    authToken: String?
  ) throws -> URLRequest {
    let url = try buildURL(with: data)
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = data.httpMethod.rawValue
    
    if !data.headers.isEmpty {
      urlRequest.allHTTPHeaderFields = data.headers
    }
    
    if data.addAuthorizationToken {
      if let authToken = authToken {
        urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
      } else {
        throw RemoteAPIManagerError.missingToken
      }
    }
    
    if let encodable = data as? Encodable {
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try JSONEncoder().encode(encodable)
    }
    
    return urlRequest
  }
  
  private func buildURL(with data: RequestProtocol) throws -> URL {
    var components = URLComponents(string: baseURL)!
    components.path = "/api" + data.path
    components.queryItems = data.queryItems.map { URLQueryItem(name: $0, value: $1) }
    
    if let url = components.url {
      return url
    } else {
      throw RemoteAPIManagerError.invalidURL
    }
  }
}

enum RemoteAPIManagerError: Error {
    case invalidURL
    case missingToken
    case unauthorized
}
