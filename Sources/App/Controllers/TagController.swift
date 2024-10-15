//
//  TagController.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

struct TagController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let tags = routes.grouped("tags")
        
        // MARK: 批量创建 Tags
        tags.post("batch-create") { req async throws -> [TagModel] in
            
            let createdTags = try req.content.decode([TagModel].self)
            
            let savedTags = try await withThrowingTaskGroup(of: TagModel.self) { taskGroup in
                createdTags.forEach { tag in
                    taskGroup.addTask {
                        try await tag.save(on: req.db)
                        return tag
                    }
                }
                var results = [TagModel]()
                for try await result in taskGroup {
                    results.append(result)
                }
                return results
            }
            return savedTags
        }
    }
}
