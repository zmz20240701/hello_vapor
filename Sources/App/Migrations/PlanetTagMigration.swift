//
//  PlanetTagMigration.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

struct PlanetTagMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        
        try await database.schema("planet+tag")
            .id()
            .field("comments", .string)
            .field("planet_id", .uuid, .references("planets", "id", onDelete: .cascade))
            .field("tag_id", .uuid, .references("tags", "id", onDelete: .cascade))
            .unique(on: "planet_id", "tag_id")
            .create()
    }
    func revert(on database: any Database) async throws {
        try await database.schema("planet+tag").delete()
    }
}

/// 在 planet+tag 表中，你希望确保每个 planet 和 tag 的组合只出现一次。比如：

/// •    你可以有 planet_id = 1 和 tag_id = 1 的记录；
/// •    你也可以有 planet_id = 2 和 tag_id = 1 的记录；
/// •    但是，你不能有两个 planet_id = 1 和 tag_id = 1 的记录，因为这违反了组合唯一性约束。
