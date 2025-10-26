//
//  RequestProtocol.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 15.12.2024.
//

import Foundation

protocol RequestProtocol {
  var path: String { get }
  var httpMethod: HTTPMethod { get }
  var queryItems: [String: String?] { get }
  var headers: [String: String] { get }
  var addAuthorizationToken: Bool { get }
}

extension RequestProtocol {
  var queryItems: [String: String?] {
    [:]
  }
  
  var headers: [String: String] {
    [:]
  }
  
  var addAuthorizationToken: Bool {
    true
  }
}
