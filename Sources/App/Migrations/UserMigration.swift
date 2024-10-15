//
//  UserMigration.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//
import Foundation
import Vapor
import Fluent

struct UserMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("firstname", .string, .required)
            .field("lastname", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("address_city", .string)
            .field("address_street", .string)
            .field("address_zip_code", .string)
            .field("createdAt", .date)
            .field("updatedAt", .date)
        
            .create()
    }
    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .delete()
    }
}
