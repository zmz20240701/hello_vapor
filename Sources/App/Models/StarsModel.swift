//
//  StarsModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//
import Foundation
import Vapor
import Fluent
final class StarsModel: Content, Model, @unchecked Sendable {
    static let schema: String = "stars"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Parent(key: "galaxy_id")
    var galaxy: GalaxyModel
    
    @Children(for: \.$star)
    var planets: [PlanetModel]
    
    init() {}
    
    init(id: UUID? = nil, name: String, galaxyID: UUID) {
        self.id = id
        self.name = name
        self.$galaxy.id = galaxyID
    }
}
