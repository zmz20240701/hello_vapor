//
//  UserModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//

import Foundation
import Vapor
import Fluent
import SwiftyBeaver



final class UserModel: Content, Model, @unchecked Sendable {
    static let schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "firstname")
    var firstname: String
    
    @Field(key: "lastname")
    var lastname: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Group(key: "address")
    var address: Address
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    
    init() { log.info("不确定这里需不需要可选") }
    
    init(id: UUID? = nil, firstname: String, lastname: String, email: String, password: String) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.password = password
    }
}
