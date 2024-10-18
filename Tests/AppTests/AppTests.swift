@testable import App
import XCTVapor
import Fluent

final class AppTests: XCTestCase {
	
		/// app 是一个 Application 实例,它将被初始化为 Vapor 应用, 用于执行测试;
	var app: Application!
	/// setUp 是一个生命周期方法, 每个测试方法执行前都会调用它;
	override func setUp() async throws {
		/// 使用`.testing`环境初始化 Application 实例;
		self.app = try await Application.make(.testing)
		/// 将项目配置应用到测试中的 app 实例;
		try await configure(app)
		/// 确保测试时, 数据库结构是最新的;
		try await app.autoMigrate()
	}
	/// tearDown 是一个生命周期方法, 每个测试方法执行后都会调用它;
	override func tearDown() async throws {
		/// 自动撤销数据库迁移, 将数据库还原为测试前的状态;
		try await app.autoRevert()
		/// 异步关闭 app 释放与应用相关的;
		try await self.app.asyncShutdown()
		/// 清空当前应用的实例. 确保每一个测试运行的都是一个全新的 Application 实例;
		self.app = nil
	}
		/// 测试函数以 test 开头
	func testHelloWorld() async throws {
		try await self.app.test(.GET, "hello") { res async in // 可以在闭包中执行异步代码
			XCTAssertEqual(res.status, .ok)
			XCTAssertEqual(res.body.string, "Hello, world")
		}
	}
}


/// 在 Vapor 中 Application 是应用的核心对象, 它封装了服务器的整个生命周期;
/// 被实例化的 app 可以管理所有域服务器有关的内容; 包括:
/// 1. 配置环境;
/// 2. 配置服务器路由;
/// 3. 管理 HTTP 请求与相应;
/// 4. 中间件管理;
/// 5. 数据库管理;
/// 6. 资源管理. 比如线程池, 数据库连接, 日志处理等;
