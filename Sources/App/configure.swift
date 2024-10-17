import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import DotEnv
import Foundation
import SwiftyBeaver
import Redis
import NIOCore

let log = SwiftyBeaver.self // 在全局范围定义日志实例

public func configure(_ app: Application) async throws {
    
    
    // Serves files from `Public/` directory
    // 使用 FileMiddleware 提供 Public 文件夹中的静态文件
    let fileMiddleware = try FileMiddleware(bundle: .main, publicDirectory: "Public")
    app.middleware.use(fileMiddleware)
    
    
    
    
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
//    app.logger.logLevel = .debug // 启用Fulent SQL语句的日志记录
    
    let file = FileDestination()
    file.logFileURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Logs/myApp.log")
    file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L [$F:$l] $M $X"
    log.addDestination(file)
    
    let console = ConsoleDestination()
    console.format = "$DHH:mm:ss$d $L [$F:$l:$N] $M $X"
    log.addDestination(console)
    
    log.info("这是一个信息日志")
    
    
    switch app.environment {
    case .production:
        // 配置 TLS/SSL 证书以启用安全连接
        var tls = TLSConfiguration.clientDefault
        tls.certificateVerification = .fullVerification
        tls.trustRoots = .file(ProcessInfo.processInfo.environment["ROOT_CERT"] ?? "not set")
        // MARK: 数据库配置
        app.databases.use(DatabaseConfigurationFactory.mysql(
            hostname: ProcessInfo.processInfo.environment["DATABASE_HOST"] ?? "not set",
            port: ProcessInfo.processInfo.environment["DATABASE_PORT"].flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ?? "not set",
            password: ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? "not set",
            database: ProcessInfo.processInfo.environment["DATABASE_NAME"] ?? "not set",
            tlsConfiguration: tls
        ), as: .mysql)
        
        // MARK: Redis 配置
        // 创建多个 Redis 服务器地址的 SocketAddress 集合
        let serverAddresses: [SocketAddress] = [
            try .makeAddressResolvingHost("localhost", port: 6379),
            try .makeAddressResolvingHost("localhost", port: 6380),
            try .makeAddressResolvingHost("localhost", port: 6381)
        ]

        // 设置连接池选项
        let poolOptions = RedisConfiguration.PoolOptions(
            maximumConnectionCount: .maximumActiveConnections(10), // 设置最大连接数
            minimumConnectionCount: 5, // 设置最小连接数
            connectionBackoffFactor: 2, // 设置连接重试时的回退因子
            initialConnectionBackoffDelay: .milliseconds(100) // 设置初始连接回退延迟
        )

        // 创建 Redis 配置
        let redisConfig = try RedisConfiguration(
            serverAddresses: serverAddresses,
            password: "your_password", // 设置密码
            database: 0, // 选择数据库索引
            pool: poolOptions // 使用连接池选项
        )

        // 将配置添加到应用中
        app.redis.configuration = redisConfig
        
    case .testing:
        
        var tls = TLSConfiguration.clientDefault
        tls.certificateVerification = .fullVerification
        tls.trustRoots = .file(ProcessInfo.processInfo.environment["ROOT_CERT"] ?? "not set")
        
        app.databases.use(DatabaseConfigurationFactory.mysql(
            hostname: ProcessInfo.processInfo.environment["DATABASE_HOST"] ?? "not set",
            port: ProcessInfo.processInfo.environment["DATABASE_PORT"].flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ?? "not set",
            password: ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? "not set",
            database: ProcessInfo.processInfo.environment["DATABASE_NAME"] ?? "not set",
            tlsConfiguration: tls
        ), as: .mysql)
        
        let serverAddresses: [SocketAddress] = [
          try .makeAddressResolvingHost("localhost", port: 6379),
          try .makeAddressResolvingHost("localhost", port: 6380),
          try .makeAddressResolvingHost("localhost", port: 6381)
        ]
        let poolOptions = RedisConfiguration.PoolOptions(
            maximumConnectionCount: .maximumActiveConnections(10),
            minimumConnectionCount: 5,
            connectionBackoffFactor: 2,
            initialConnectionBackoffDelay: .milliseconds(100)
            )
        let redisConfig = try RedisConfiguration(
            serverAddresses: serverAddresses,
            password: "000",
            database: 0,
            pool: poolOptions
        )
        app.redis.configuration = redisConfig
        
    case .development:
        var tls = TLSConfiguration.makeClientConfiguration()
        tls.certificateVerification = .none
        
        app.databases.use(DatabaseConfigurationFactory.mysql(
            hostname: ProcessInfo.processInfo.environment["DATABASE_HOST"] ?? "not set",
            port: ProcessInfo.processInfo.environment["DATABASE_PORT"].flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ?? "not set",
            password: ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? "not set",
            database: ProcessInfo.processInfo.environment["DATABASE_NAME"] ?? "not set",
            tlsConfiguration: tls
        ), as: .mysql)
        
        app.redis.configuration = try RedisConfiguration(hostname: "localhost", port: 6379)
        
        
    default:
        break
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
    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))
    app.sessions.use(.redis)
    
    
    
    // MARK: 配置路由
    try routes(app)
}
