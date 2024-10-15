import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import DotEnv
import Foundation
import SwiftyBeaver

let log = SwiftyBeaver.self // 在全局范围定义日志实例

public func configure(_ app: Application) async throws {
    // MARK: 环境变量文件引入
    let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let pool = NIOThreadPool(numberOfThreads: 1)
    pool.start()
    let fileio = NonBlockingFileIO(threadPool: pool)
    let envFile = ".env." + app.environment.name
    try await DotEnv.load(path: app.directory.workingDirectory + envFile, fileio: fileio, on: elg.next()).get()
    try await pool.shutdownGracefully()
    try await elg.shutdownGracefully()
    
    // MARK: 日志配置
    app.logger.logLevel = .debug // 启用Fulent SQL语句的日志记录
    
    let file = FileDestination()
    file.logFileURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Logs/myApp.log")
    file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L [$F:$l] $M $X"
    log.addDestination(file)
    
    let console = ConsoleDestination()
    console.format = "$DHH:mm:ss$d $L [$F:$l:$N] $M $X"
    log.addDestination(console)
    
    log.info("这是一个信息日志")

    // MARK: 数据库配置
    switch app.environment {
    case .production:
        app.databases.use(DatabaseConfigurationFactory.mysql(
            hostname: ProcessInfo.processInfo.environment["DATABASE_HOST"] ?? "localhost",
            port: ProcessInfo.processInfo.environment["DATABASE_PORT"].flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ?? "vapor_username",
            password: ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? "vapor_password",
            database: ProcessInfo.processInfo.environment["DATABASE_NAME"] ?? "vapor_database"
        ), as: .mysql)
    case .testing:
        // 配置 TLS/SSL 证书以启用安全连接
        var tls = TLSConfiguration.makeClientConfiguration()
        tls.certificateVerification = .fullVerification
        tls.trustRoots = .file("/etc/letsencrypt/live/bayanarabic.cn/fullchain.pem")
        app.databases.use(DatabaseConfigurationFactory.mysql(
            hostname: ProcessInfo.processInfo.environment["DATABASE_HOST"] ?? "localhost",
            port: ProcessInfo.processInfo.environment["DATABASE_PORT"].flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ?? "vapor_username",
            password: ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? "vapor_password",
            database: ProcessInfo.processInfo.environment["DATABASE_NAME"] ?? "vapor_database",
            tlsConfiguration: tls
        ), as: .mysql)
    case .development:
        var tls = TLSConfiguration.makeClientConfiguration()
        tls.certificateVerification = .none
        
        app.databases.use(DatabaseConfigurationFactory.mysql(
            hostname: ProcessInfo.processInfo.environment["DATABASE_HOST"] ?? "localhost",
            port: ProcessInfo.processInfo.environment["DATABASE_PORT"].flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ?? "vapor_username",
            password: ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? "vapor_password",
            database: ProcessInfo.processInfo.environment["DATABASE_NAME"] ?? "vapor_database",
            tlsConfiguration: tls
        ), as: .mysql)

    default:
        let foo = ProcessInfo.processInfo.environment["FOO"]
        print(foo ?? "FOO not found")
    }


    // MARK: 配置迁移
    app.migrations.add(GalaxyMigration())
    app.migrations.add(StarMigration())
    app.migrations.add(PetMigration())
    app.migrations.add(CustomerMigration())
    app.migrations.add(UserMigration())
    app.migrations.add(PlanetMigration())
    app.migrations.add(GovernorMigration())
    app.migrations.add(TagMigration())
    app.migrations.add(PlanetTagMigration())
    
    try await app.autoMigrate()
    
    // MARK: 配置中间件
    app.databases.middleware.use(PlanetMiddleware(), on: .mysql)
    
    
    // MARK: 配置路由
    try routes(app)
}
