//
//  UserDTO.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//
import Foundation
import Vapor
import Fluent

struct CreateUserDTO: Content {
    var firstname: String
    var lastname: String
    var email: String
    var password: String
}
struct LoginDTO: Content {
    var email: String
    var password: String
}
struct UpdateUserDTO: Content {
    var firstname: String?
    var lastname: String?
    var email: String?
    var city: String?
    var street: String?
    var zipCode: String?
    var updatedAt: Date?
}

struct GetUserDTO: Content {
    var id: UUID?
    var name: String
    var email: String
    var createdAt: Date?
    var updatedAt: Date?
    
    init(from user: UserModel) {
        self.id = user.id
        self.name = "\(user.firstname) \(user.lastname)"
        self.email = user.email
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
    }
}
