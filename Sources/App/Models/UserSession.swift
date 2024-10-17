//

//  UserSession.swift
//  hello
//
//  Created by 赵康 on 2024/10/17.
//
import Foundation
import Vapor
import Redis

struct UserSession: Content {
    var username: String
    var email: String
}

// 扩展 UserSession 使其符合 RESPValueConvertible 协议
extension UserSession: RESPValueConvertible {
    // 将 UserSession 转换为 RESPValue（存储到 Redis）
    public func convertedToRESPValue() -> RESPValue {
        // 使用 JSON 编码将 UserSession 转换为 Data
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return .null
        }
        return .init(from: jsonData)
    }

    // 从 RESPValue 转换为 UserSession（从 Redis 获取）
    public init?(fromRESP value: RESPValue) {
        // 获取 RESPValue 中的数据
        guard let jsonData = value.string?.data(using: .utf8) else {
            return nil
        }
        // 尝试解码为 UserSession
        guard let session = try? JSONDecoder().decode(UserSession.self, from: jsonData) else {
            return nil
        }
        self = session
    }
}
