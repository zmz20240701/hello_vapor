//
//  PlanetMigration.swift
//  hello
//
//  Created by 赵康 on 2024/10/11.
//

import Foundation
import Vapor
import Fluent

struct PlanetMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let planetType = try await database.enum("planet_type")
            .case("gas_giant")
            .case("terrestrial")
            .case("ice_giant")
            .case("dwarf")
        
            .create()
        
        try await database.schema("planets")
        
            .id()
            .field("name", .string, .required)
            .field("type", planetType, .required)
            .field("star_id", .uuid, .references("stars", "id"))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("planets").delete() //先删除表
        try await database.enum("planet_type").delete()
        
    }
    
}
