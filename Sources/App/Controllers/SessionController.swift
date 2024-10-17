//
//  SessionController.swift
//  hello
//
//  Created by 赵康 on 2024/10/17.
//

import Foundation
import Vapor
import Fluent
import Redis

struct SessionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let sessionRoutes = routes.grouped("session")
    }
    @Sendable
    /// `map`的作用就是在已有的异步操作完成后,对操作返回的结果做一个简单的映射,并返回一个新的
    /// `EventLoopFuture`但是不会引入新的异步操作,也不会阻塞;
    /// 这里边req.redis.set返回的是一个`EventLoopFuture<Void>`,通过 map 将其转换为
    /// `EventLoopFuture<String>`
    func createSession(req: Request) throws -> EventLoopFuture<String> {
        let userSession = try req.content.decode(UserSession.self)
        let sessionID = RedisKey("session_\(userSession.username)")
        return req.redis.set(sessionID, to: userSession).map { _ in
            return "Session created for \(userSession.username)"
        }
    }
    @Sendable
    func getSession(req: Request) throws -> EventLoopFuture<UserSession> {
        guard let username = req.query[String.self, at: "username"]
        else {
            throw Abort(.notFound, reason: "Missing username")
        }
        let sessionID = RedisKey("session_\(username)")
        
        return req.redis.get(sessionID, as: UserSession.self).unwrap(or: Abort(.notFound))
    }
    @Sendable
    func deleteSession(req: Request) throws -> EventLoopFuture<String> {
        guard let username = req.query[String.self, at: "username"]
        else {
            throw Abort(.notFound)
        }
        let sessionID = RedisKey("session_\(username)")
        return req.redis.delete(sessionID).map { _ in
            return "Session deleted for \(username)"
        }
    }
}
