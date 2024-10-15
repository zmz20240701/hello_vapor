//
//  PlanetTagController.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

struct PlanetTagController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let planetTags = routes.grouped("planet-tags")
        
        
       // MARK: 创建单个PlanetTag
        planetTags.post { req async throws -> PlanetTagModel in
            let createdPlanetTag = try req.content.decode(CreatePlanetTagDTO.self)
           guard
            let planet = try await PlanetModel.find(createdPlanetTag.planetID, on: req.db)
            else {
                throw Abort(.notFound, reason: "没有找到对应的Planet")
           }
            guard
            let tag = try await TagModel.find(createdPlanetTag.tagID, on: req.db)
            else {
                throw Abort(.notFound, reason: "没有找到对应的Tag")
            }
            let planetTag = try PlanetTagModel(comments: createdPlanetTag.comments,  planet: planet, tag: tag)
            try await planetTag.save(on: req.db)
            return planetTag
        }
        
        //MARK: 获取全部PlanetTag
        planetTags.get { req async throws -> [PlanetTagModel] in
            let planetTags = try await PlanetTagModel.query(on: req.db)
                .with(\.$tag)
                .with(\.$planet)
                .all()
            return planetTags
            }
        }
    }

