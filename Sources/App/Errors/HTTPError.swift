//
//  HTTPError.swift
//  hello
//
//  Created by 赵康 on 2024/10/9.
//

import Vapor
enum HTTPError {
    case userNotLoggedIn
    case invalidEmail
}
extension HTTPError: AbortError {
    var reason: String {
        switch self {
        case .userNotLoggedIn:
            return "请您先登录"
        case .invalidEmail:
            return "你输入的地址无效"
        }
    }
    var status: HTTPResponseStatus {
        switch self {
        case .userNotLoggedIn:
            return .unauthorized
        case .invalidEmail:
            return .badRequest
        }
    }
}
