//
//  Pet.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//

import Foundation
import Vapor
import Fluent

final class Pet: Model, Content, @unchecked Sendable {
    static let schema: String = "pets"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Enum(key: "type")
    var type: Animal
    
    init() {}
    
    init(id: UUID? = nil, name: String, type: Animal) {
        self.id = id
        self.name = name
        self.type = type
    }
}

enum Animal: String, Codable, CaseIterable {
    case dog, cat
}
