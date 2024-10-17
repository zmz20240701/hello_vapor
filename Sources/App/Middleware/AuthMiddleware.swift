//
//  AuthMiddleware.swift
//  hello
//
//  Created by 赵康 on 2024/10/17.
//

import Foundation
import Vapor
import Fluent
import Redis

//struct AuthMiddleware: AsyncMiddleware {
//    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
//        // 检查会话 ID 是否存在
//        guard
//            let sessionID = request.session.id
//        else {
//            throw Abort(.unauthorized, reason: "用户未登录")
//        }
//        
//        let sessionKey = RedisKey("session_\(sessionID)")
//        return request.redis.get(sessionKey).flatMap { userID in
//            request.session.data["userID"] = userID.string
//            return try await next.respond(to: request)
//        }
//        
//    }
//}
struct AuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: any Responder) -> EventLoopFuture<Response> {
        // 从请求中获取会话 ID
        guard let sessionID = request.session.id?.string else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Session ID is missing"))
        }
        
        print("Session ID from request: \(sessionID)")

        let sessionKey = RedisKey("session_\(sessionID)") // 确保使用和存储时一致的键
        print("Redis sessionKey: \(sessionKey)")

        // 从 Redis 中检索会话信息
        return request.redis.get(sessionKey).flatMap { userID in
            print("Retrieved userID from Redis: \(String(describing: userID))")
            
            guard let userIDString = userID.string else {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Session expired or invalid"))
            }

            // 存储用户 ID
            request.session.data["userID"] = userIDString
            print("Authenticated User ID: \(userIDString)")

            return next.respond(to: request)
            // 这个方法本身也是异步的,返回的是一个EventLoopFuture<Response>
        }
    }
}

/// 每一个 Request 都由一个EventLoop来处理, 它专门负责处理异步请求的逻辑;
/// `request.eventLoop`可以访问当前请求的EventLoop实例
/// `EventLoopFuture`是 Vapor 的核心异步处理机制;
