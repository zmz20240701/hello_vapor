//
//  GalaxyModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/9.
//
import Foundation
import Vapor
import Fluent

final class GalaxyModel: Model, Content, @unchecked Sendable {
    
    // MARK: 指定表名
    static let schema = "galaxies"
    
    // MARK: 指定表头
    @ID(key: .id)
    var id: UUID?
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$galaxy) // 跟子表中的属性名相同我们的StartModel中就有一个属性叫做galaxy
    var stars: [StarsModel]
    
    // MARK: 创建新实例
    init(){}
    
    // MARK: 创建初始化器
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
}
