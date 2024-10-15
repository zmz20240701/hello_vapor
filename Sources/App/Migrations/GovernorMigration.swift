//
//  GovernorMigration.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

struct GovernorMigration: AsyncMigration {
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("governors").delete()
    }
    
    func prepare(on database: any Database) async throws {
        try await database.schema("governors")
        
            .id()
            .field("name", .string, .required)
            .field("planet_id", .uuid, .references("planets", "id"))
            .create()
    }
}
