//
//  PlanetTagDTO.swift
//  hello
//
//  Created by 赵康 on 2024/10/12.
//

import Foundation
import Vapor
import Fluent

struct CreatePlanetTagDTO: Content {
    let comments: String?
    let planetID: UUID
    let tagID: UUID
}
