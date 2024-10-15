//
//  PetController.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//
import Foundation
import Vapor
import Fluent

struct PetController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let pets = routes.grouped("pets")
        
        pets.post(use: self.create)
        pets.get(use: self.read)
    }
    
    @Sendable
    func create(req: Request) async throws -> Pet {
        let pet = try req.content.decode(Pet.self)
        try await pet.create(on: req.db)
        return pet
    }
    
    @Sendable
    func read(req: Request) async throws -> [Pet] {
        try await Pet.query(on: req.db).all()
    }
}
