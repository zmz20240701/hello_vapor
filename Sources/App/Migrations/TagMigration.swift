//
//  TagMigration.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

struct TagMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("tags")
            .id()
            .field("name", .string, .required)
            .create()
    }
    func revert(on database: any Database) async throws {
        try await database.schema("tags").delete()
    }
}
