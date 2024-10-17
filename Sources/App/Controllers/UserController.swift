import Fluent
import Vapor
import Redis



struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: self.create)
        users.patch(":id", use: self.update)
        users.get(":id", use: self.read)
        let auth = routes.grouped("auth")
        auth.post("login", use: self.login)
        auth.post("logout", use: self.logout)
               
        
        // 要读取全部的用户必须是已经登录的用户
        let protectedUsers = users.grouped(AuthMiddleware())
        protectedUsers.get("all", use: readAll)
    }
    
    @Sendable
    func login(req: Request) -> EventLoopFuture<HTTPStatus> {
        // 解析登录请求数据
        let loginData: LoginDTO
        do {
            loginData = try req.content.decode(LoginDTO.self)
        } catch {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "请求数据格式错误"))
        }

        // 查询用户是否存在
        return UserModel.query(on: req.db)
            .filter(\.$email == loginData.email)
            .first()
            .flatMap { user in
                // 如果用户不存在
                guard let user = user else {
                    return req.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "当前邮箱未注册"))
                }

                // 验证密码
                do {
                    let isPasswordValid = try Bcrypt.verify(loginData.password, created: user.password)
                    if !isPasswordValid {
                        return req.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "密码不正确"))
                    }
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }

                // 生成会话 ID（不加密，确保一致）
                let sessionID = UUID().uuidString
                req.session.id = SessionID(string: sessionID)
                req.session.data["userID"] = user.id?.uuidString

                print("Session ID: \(sessionID)")
                print("User ID: \(user.id?.uuidString ?? "nil")")

                // 创建 Redis 键并存储会话信息
                let sessionKey = RedisKey("session_\(sessionID)")  // 使用原始 sessionID
                print("Redis sessionKey: \(sessionKey)")
                return req.redis.set(sessionKey, to: user.id?.uuidString).transform(to: .ok)
            }
    }
    
    @Sendable
    func logout(req: Request) async throws -> HTTPStatus {
        guard let sessionID = req.session.id
        else {
            throw Abort(.unauthorized, reason: "用户未登录")
        }
        // 删除 Redis中的会话信息
        let sessionKey = RedisKey("session_\(sessionID)")
        _ = req.redis.delete(sessionKey)
        
        // 销毁会话
        req.session.destroy()
        
        return .ok
    }
    @Sendable
    func create(req: Request) async throws -> Vapor.HTTPStatus {
        let createdUser = try req.content.decode(CreateUserDTO.self)
        let user = UserModel()
        user.firstname = createdUser.firstname
        user.lastname = createdUser.lastname
        user.email = createdUser.email
        user.password = try Bcrypt.hash(createdUser.password)
        user.createdAt = Date()
        
        try await user.create(on: req.db)
        
        let userKey = RedisKey("user_\(user.id)")
        let userDTO = GetUserDTO(from: user)
        let jsonData = try JSONEncoder().encode(userDTO)
        
        _ = req.redis.set(userKey, to: jsonData)
        return .created
    }
    
    @Sendable
    func update(req: Request) async throws -> GetUserDTO {
        let updatedUser = try req.content.decode(UpdateUserDTO.self)
        let userID = req.parameters.get("id", as: UUID.self)
        guard
            let user = try await UserModel.find(userID, on: req.db)
        else {
            throw Abort(.notFound, reason: "用户不存在")
        }
        user.firstname = updatedUser.firstname ?? user.firstname
        user.lastname = updatedUser.lastname ?? user.lastname
        user.email = updatedUser.email ?? user.email
        user.address.city = updatedUser.city ?? user.address.city
        user.address.street = updatedUser.city ?? user.address.city
        user.address.zipCode = updatedUser.zipCode ?? user.address.city
        user.updatedAt = Date()
        
        try await user.save(on: req.db)
        
        let userKey = RedisKey("user_\(userID)")
        let userDTO = GetUserDTO(from: user)
        let jsonData = try JSONEncoder().encode(userDTO)
        _ = req.redis.set(userKey, to: jsonData)
        
        return GetUserDTO(from: user)
    }
    
    @Sendable
    func read(req: Request) async throws -> GetUserDTO {
        let userID = req.parameters.get("id", as: UUID.self)
        guard
            let user = try await UserModel.find(userID, on: req.db)
        else {
            throw Abort(.notFound, reason: "用户不存在")
        }
        return GetUserDTO(from: user)
    }
    @Sendable
    func readAll(req: Request) async throws -> [GetUserDTO] {
        let users = try await UserModel.query(on: req.db)
            .all()
        return users.map { user in
            GetUserDTO(from: user)
        }
    }
}

