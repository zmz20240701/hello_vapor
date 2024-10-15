//
//  PlanetMiddleware.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

final class PlanetMiddleware: AsyncModelMiddleware {
    
    func create(model: PlanetModel, on db: Database, next: AnyAsyncModelResponder) async throws {
        print("Before creating planet: \(model.name)")
        model.name = model.name.uppercased()
        try await next.create(model, on: db)
        print("Planet \(model.name) created!")
    }
    
    func delete(model: PlanetModel, force: Bool, on db: any Database, next: any AnyAsyncModelResponder) async throws {
        print("Before deleting planet \(model.name)")
        try await next.delete(model, force: force, on: db)
        print("Planet \(model.name) deleted!")
    }
}

//中间件不需要调用, 直接定义方法, 并在配置文件中加入即可
