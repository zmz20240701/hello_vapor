//
//  StarMigration.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//
import Foundation
import Vapor
import Fluent

struct StarMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("stars")
        
            .id()
            .field("name", .string)
            .field("galaxy_id", .uuid, .references("galaxies", "id"))
        
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("stars").delete()
    }
}
