//
//  CustomerMigration.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//

import Foundation
import Vapor
import Fluent

struct CustomerMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("customers")
            .id()
            .field("name", .string, .required)
            .field("address_street", .string, .required)
            .field("address_city", .string, .required)
            .field("address_zip_code", .string, .required)
        
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("customers").delete()
    }
}

