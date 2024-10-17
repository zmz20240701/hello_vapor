//
//  UserModel.swift
//  hello
//
//  Created by 赵康 on 2024/10/10.
//

import Foundation
import Vapor
import Fluent
import SwiftyBeaver
import Redis



final class UserModel: Content, Model, @unchecked Sendable {
    static let schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "firstname")
    var firstname: String
    
    @Field(key: "lastname")
    var lastname: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Group(key: "address")
    var address: Address
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    
    init() { log.info("不确定这里需不需要可选") }
    
    init(id: UUID? = nil, firstname: String, lastname: String, email: String, password: String) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.password = password
    }
}

// 扩展 UserModel 使其符合 RESPValueConvertible 协议
extension UserModel: RESPValueConvertible {
    // 将 UserModel 转换为 RESPValue
    public func convertedToRESPValue() -> RESPValue {
        // 使用 JSON 编码将 UserModel 转换为 Data
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return .null
        }
        return .init(from: jsonData)
    }

    // 从 RESPValue 转换为 UserModel（从 Redis 获取）
    public convenience init?(fromRESP value: RESPValue) {
        guard let jsonData = value.string?.data(using: .utf8) else {
            return nil
        }
        // 尝试解码为 UserSession
        guard let user = try? JSONDecoder().decode(UserModel.self, from: jsonData) else {
            return nil
        }
        // 使用解码后的 UserModel 数据初始化当前实例
        self.init(id: user.id, firstname: user.firstname, lastname: user.lastname, email: user.email, password: user.password)
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
        self.address = user.address
    }
}
