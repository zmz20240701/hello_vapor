import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: self.create)
        users.patch(":id", use: self.update)
        users.get(":id", use: self.read)
        users.get(use: self.readAll)
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
