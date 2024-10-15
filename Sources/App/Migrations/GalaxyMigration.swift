import Fluent
import Vapor


struct GalaxyMigration: AsyncMigration {
    
    // MARK: 执行迁移
    func prepare(on database: Database) async throws {
        // 创建表的模板; 必须跟Model里的模板一致哦!
        try await database.schema("galaxies")
            .id()
            .field("name", .string, .required)
            .create()
        // 填充一些数据
        let galaxies = [
            GalaxyModel(name: "Milky Way"),
            GalaxyModel(name: "Andromeda"),
            GalaxyModel(name: "Sombrero"),
        ]
        for galaxy in galaxies {
            try await galaxy.create(on: database)
        }
    }
    // MARK: 回滚迁移
    func revert(on database: Database) async throws {
        try await database.schema("galaxies").delete()
    }
}

/// 迁移指的是数据库结构的变化过程, 比如创建表, 修改表, 添加字段等;
/// 通过迁移, 保证你应用的模型和数据库的结构一致;
