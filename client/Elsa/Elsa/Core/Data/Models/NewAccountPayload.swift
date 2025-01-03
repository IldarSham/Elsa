//
//  RegisterAccountData.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 19.12.2024.
//

import Foundation

struct NewAccountPayload: Encodable {
  let firstName: String
  let lastName: String
  let email: String
  let password: String
}
