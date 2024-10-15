//
//  PlanetController.swift
//  hello
//
//  Created by 赵康 on 2024/10/11.
//

import Foundation
import Vapor
import Fluent

struct PlanetController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let planets = routes.grouped("planets")
        //        planets.post(use: self.create)
        planets.get(use: getPlanetsAroundSun)
        planets.get("gasGiant", use: readGasGiant)
        
        // MARK: 批量创建planet
        planets.post("batch") { req async throws -> HTTPStatus in
            let planets = try req.content.decode([PlanetModel].self)
            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                planets.forEach { planet in
                    taskGroup.addTask { try await planet.create(on: req.db) }
                }
                try await taskGroup.waitForAll()
            }
            return .ok
        }
        
        // MARK: 删除指定的planet
        planets.delete(":id") { req async throws -> HTTPStatus in
            let planetID = req.parameters.get("id", as: UUID.self)
            guard
                let planet = try await PlanetModel.find(planetID, on: req.db)
            else {
                throw Abort(.notFound, reason: "查找的星球不存在")
            }
            try await planet.delete(on: req.db)
            return .ok
        }
        
        planets.get("governor") { req async throws -> PlanetModel in
            guard
            let planetWithGovernor = try await PlanetModel.query(on: req.db)
                .with(\.$governor)
                .filter(\.$name == "Pluto")
                .first()
            else {
                throw Abort(.notFound, reason: "没有找到叫做Pluto的星球")
            }
            return planetWithGovernor
        }

        @Sendable
        func create(req: Request) async throws -> PlanetModel {
            let planet = try req.content.decode(PlanetModel.self)
            try await planet.save(on: req.db)
            return planet
        }
        
        @Sendable
        func readNames(req: Request) async throws -> [String] {
            // 只获取模型中的某一个属性
            try await req.db.query(PlanetModel.self).all(\.$name)
            // 另一种常用写法 try await PlanetModel.query(on: req.db)
        }
        
        @Sendable
        func readGasGiant(req: Request) async throws -> [PlanetModel] {
            try await PlanetModel.query(on: req.db)
                .filter(\.$type == .gas_giant)
                .sort(\.$name)
                .with(\.$star)
                .all()
        }
        // MARK: 演示
        @Sendable
        func readByFilter(req: Request) async throws -> [PlanetModel] {
            try await PlanetModel.query(on: req.db)
                .group(.or) { orGroup in
                    orGroup.filter(\.$name == "Earth")
                    orGroup.filter(\.$name == "Mars")
                    orGroup.group(.and) { andGroup in
                        andGroup.filter(\.$type ~~ [.gas_giant, .dwarf]) // 包含
                        andGroup.filter(\.$name =~ "Ne" ) // 前缀匹配
                        // 后缀匹配 ~=
                    }
                }
                .all()
        }
        @Sendable
        func getPlanetsAroundSun(req: Request) async throws -> [PlanetModel] {
            return try await PlanetModel.query(on: req.db)
                .join(StarsModel.self, on: \PlanetModel.$star.$id == \StarsModel.$id) // 将 Star 模型通过 star_id 与 Planet 关联
                .filter(StarsModel.self, \.$name == "Sun") // 过滤条件：只获取与 Sun 相关联的行星
                .all()
        }
        
    }
}
