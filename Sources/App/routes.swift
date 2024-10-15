import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    app.get("galaxies") { req async throws -> [GalaxyModel] in
        try await GalaxyModel.query(on: req.db)
            .with(\.$stars) //连带显示子表信息,否则略过此键
            .all()
    }
    app.post("stars") { req async throws in
        let star = try req.content.decode(StarsModel.self)
        try await star.create(on: req.db)
        return star
    }
    app.get("stars") { req async throws -> [StarsModel] in
        try await StarsModel.query(on: req.db)
            .with(\.$galaxy) //连带显示galaxy的信息,否则只显示一个 id
            .all()
    }
    
    try app.register(collection: PetController())
    try app.register(collection: CustomerController())
    try app.register(collection: UserController())
    try app.register(collection: PlanetController())
    try app.register(collection: GovernorController())
    try app.register(collection: TagController())
    try app.register(collection: PlanetTagController())
    
}
