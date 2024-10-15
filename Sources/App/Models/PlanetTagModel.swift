//
//  PlanetTagModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

final class PlanetTagModel: Content, Model, @unchecked Sendable {
    static let schema: String = "planet+tag"
    
    @ID(key: .id)
    var id: UUID?
    
    @OptionalField(key: "comments")
    var comments: String?
    
    @Parent(key: "planet_id")
    var planet: PlanetModel
    
    @Parent(key: "tag_id")
    var tag: TagModel
    
    init() { }
    
    init(id: UUID? = nil, comments: String? = nil,  planet: PlanetModel, tag: TagModel) throws { // 初始值类型也不同
        self.id = id
        self.comments = comments ?? ""
       
        self.$planet.id = try planet.requireID()
        self.$tag.id = try tag.requireID()  // 注意这里跟普通的父属性初始化不同
    }
}

