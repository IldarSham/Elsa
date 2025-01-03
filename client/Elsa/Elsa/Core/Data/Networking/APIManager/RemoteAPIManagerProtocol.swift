//
//  RemoteAPIManagerProtocol.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 18.12.2024.
//

import Foundation

protocol RemoteAPIManagerProtocol {
  func callAPI<T: Decodable>(with data: RequestProtocol,
                             authToken: String?) async throws -> T
  
  func callAPI<T: Decodable>(with data: LiveRequestProtocol,
                             authToken: String?) async throws -> AsyncStream<T>
}

extension RemoteAPIManagerProtocol {
  
  func callAPI<T: Decodable>(with data: RequestProtocol, authToken: String? = nil) async throws -> T {
    return try await callAPI(with: data, authToken: authToken)
  }
  
  func callAPI<T: Decodable>(with data: LiveRequestProtocol, authToken: String? = nil) async throws -> AsyncStream<T> {
    return try await callAPI(with: data, authToken: authToken)
  }
}
