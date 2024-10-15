//
//  CustomerModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//

import Foundation
import Vapor
import Fluent

final class CustomerModel: Model, Content, @unchecked Sendable {
    static let schema: String = "customers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Group(key: "address")
    var address: Address
}

final class Address: Fields, @unchecked Sendable {
    @Field(key: "street")
    var street: String?
    
    @Field(key: "city")
    var city: String?
    
    @Field(key: "zip_code")
    var zipCode: String?
}


