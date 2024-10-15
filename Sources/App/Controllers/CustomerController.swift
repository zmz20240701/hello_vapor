//
//  CustomerController.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//

import Foundation
import Vapor
import Fluent

struct CustomerController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.post(use: self.create)
        customers.get(use: self.read)
    }
    
    @Sendable
    func create(req: Request) async throws -> CustomerModel {
        let customer = try req.content.decode(CustomerModel.self)
        try await customer.create(on: req.db)
        return customer
    }
    
    @Sendable
    func read(req: Request) async throws -> [CustomerModel] {
        try await CustomerModel.query(on: req.db)
            .filter(\.$address.$city == "xinxiang")
            .all()
    }
}
