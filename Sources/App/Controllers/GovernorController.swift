//
//  GovernorController.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

struct GovernorController: RouteCollection {
    
    /// 这是路由的入口
    func boot(routes: any RoutesBuilder) throws {
        let governors = routes.grouped("governors")
        
        // MARK: 批量创建
        governors.post("creating") { req async throws -> [GovernorModel] in
            let createdGovernors = try req.content.decode([GovernorModel].self)
            let savedGovernors = try await withThrowingTaskGroup(of: GovernorModel.self) { taskGroup in
                createdGovernors.forEach { governor in
                    taskGroup.addTask { try await governor.save(on: req.db)
                        return governor
                    }
                }
                var results = [GovernorModel]()
                for try await result in taskGroup {
                    results.append(result)
                }
                return results
            }
            return savedGovernors
        }
    }
}
