//
//  UserDTO.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 05.11.2024.
//

import Vapor

struct UserDTO: Content {
  let id: User.IDValue
}
