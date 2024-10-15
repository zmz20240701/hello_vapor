//
//  TagModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

final class TagModel: Content, Model, @unchecked Sendable {
    
    static let schema: String = "tags"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Siblings(through: PlanetTagModel.self, from: \.$tag, to: \.$planet)
    public var planets: [PlanetModel]
    
    init() { }
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

// 只有 @Parent 属性是需要初始化的: 1. 多对多中间表和子属性中需要初始化; 其他的 children, sibling, optionalChild包装器都不需要初始化中表示
