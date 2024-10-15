//
//  PlanetModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/11.
//

import Foundation
import Vapor
import Fluent

final class PlanetModel: Content, Model, @unchecked Sendable {
    static let schema: String = "planets"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Enum(key: "type")
    var type: PlanetType
    
    @Parent(key: "star_id")
    var star: StarsModel
    
    @OptionalChild(for: \.$planet) // 根模型不存储子模型的值
    var governor: GovernorModel?
    
    @Siblings(through: PlanetTagModel.self, from: \.$planet, to: \.$tag) // 这里见路径的根是PlanetTagModel
    public var tags: [TagModel] // 官方说明是public
    
    init() { }
    init(id: UUID? = nil, name: String, type: PlanetType, starID: StarsModel.IDValue) {
        self.id = id
        self.name = name
        self.type = type
        self.$star.id = starID
    }
}

enum PlanetType: String, Codable {
    case gas_giant
    case terrestrial
    case ice_iant
    case dwarf
    // 模型和表格内的字符全部改成驼峰式
}
