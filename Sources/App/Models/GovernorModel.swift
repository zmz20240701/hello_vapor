//
//  GovernorModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

final class GovernorModel: Model, Content, @unchecked Sendable {
    static let schema: String = "governors"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Parent(key: "planet_id")
    var planet: PlanetModel
    init() { }
    init(id: UUID? = nil, name: String, planetID: GovernorModel.IDValue) {
        self.id = id
        self.name = name
        self.$planet.id = planetID
    }
}
