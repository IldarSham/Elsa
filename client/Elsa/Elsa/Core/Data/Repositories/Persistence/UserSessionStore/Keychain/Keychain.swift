//
//  Keychain.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 19.12.2024.
//

import Foundation

final class Keychain {
  
  // MARK: - Methods
  static func findItem(query: KeychainItemQuery) throws -> Data? {
    var queryResult: AnyObject?
    let status = withUnsafeMutablePointer(to: &queryResult) {
      SecItemCopyMatching(query.asDictionary(), UnsafeMutablePointer($0))
    }
    
    if status == errSecItemNotFound {
      return nil
    }
    guard status == noErr else {
      throw UserSessionDataStoreError.unknown
    }
    guard let itemData = queryResult as? Data else {
      throw UserSessionDataStoreError.typeCast
    }
    
    return itemData
  }
  
  static func save(item: KeychainItemWithData) throws {
    let status = SecItemAdd(item.asDictionary(), nil)
    guard status == noErr else {
      throw UserSessionDataStoreError.unknown
    }
  }
  
  static func update(item: KeychainItemWithData) throws {
    let status = SecItemUpdate(item.attributesAsDictionary(), item.dataAsDictionary())
    guard status == noErr else {
      throw UserSessionDataStoreError.unknown
    }
  }
  
  static func delete(item: KeychainItem) throws {
    let status = SecItemDelete(item.asDictionary())
    guard status == noErr || status == errSecItemNotFound else {
      throw UserSessionDataStoreError.unknown
    }
  }
}
