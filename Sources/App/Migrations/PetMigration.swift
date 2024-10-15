//
//  Pet.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//

import Foundation
import Vapor
import Fluent

struct PetMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let animal = try await database.enum("animal")
            .case("dog")
            .case("cat")
            .create()
        
        try await database.schema("pets")
        
            .id()
            .field("name", .string, .required)
            .field("type", animal, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.enum("animals").delete()
        try await database.schema("pets").delete()
    }
}
