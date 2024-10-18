	//
	//  AuthMiddleware.swift
	//  hello
	//
	//  Created by 赵康 on 2024/10/17.
	//

import Fluent
import Foundation
import Redis
import Vapor

struct AuthMiddleware: Middleware {
	func respond(to request: Request, chainingTo next: any Responder)
	-> EventLoopFuture<Response>
	{
			// 从请求中获取会话 ID
		guard let sessionID = request.session.id?.string else {
			return request.eventLoop.makeFailedFuture(
				Abort(.unauthorized, reason: "Session ID is missing"))
		}
		let sessionKey = RedisKey("session_\(sessionID)")  // 确保使用和存储时一致的键
																											 // 从 Redis 中检索会话信息
		return request.redis.get(sessionKey).flatMap { userID in
			guard let userIDString = userID.string else {
				return request.eventLoop.makeFailedFuture(
					Abort(.unauthorized, reason: "Session expired or invalid"))
			}
				// 存储用户 ID
			request.session.data["userID"] = userIDString
				/// 上边的代码是拦截 HTTP 请求,在它们到达路由控制器之前执行更改逻辑;
				///  下边这个异步代码是处理将响应返回客户端之前对响应执行一些修改逻辑
			return next.respond(to: request).map { response in
				response.headers.add(name: "my-App-Version", value: "v2.5.9")  // 在响应头中添加自定义的应用版本信息
				return response
			}
				// 这个方法本身也是异步的,返回的是一个EventLoopFuture<Response>
		}
	}
}

/// 每一个 Request 都由一个EventLoop来处理, 它专门负责处理异步请求的逻辑;
/// `request.eventLoop`可以访问当前请求的EventLoop实例
/// `EventLoopFuture`是 Vapor 的核心异步处理机制;

/// 用户登录并接受服务器在登录成功后的返回信息
//func login(email: String, password: String) {
//	let url = URL(string: "http://127.0.0.1:8080/auth/login")!
//	// 根据 URL 来配置请求, 配置请求的顺序按照 HTTP 请求的模版来;
//	var request = URLRequest(url: url)  // 基于 url 的请求;
//	request.httpMethod = "POST"
//	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//	let loginData: [String: Any] = ["email": email, "password": password]
//	request.httpBody = try? JSONSerialization.data(withJSONObject: loginData)
//	
//		// 请求配置完成, 现在准备发送; 发送是异步操作, 操作完成的逻辑由 compeltionHandler 处理
//	let task = URLSession.shared.dataTask(with: request) {  // completionHandler
//		data,
//		response,
//		error in
//		guard let data = data, error == nil else {
//			return
//		}
//			// 解析服务器返回的数据;
//		if // 如果解析成功并且 sessionID 键的值可以转化为 string
//			let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//			let sessionID = jsonData["sessionID"] as? String {
//			UserDefaults.standard.set(sessionID, forKey: "sessionID")
//			// 记住这个 key 的名称, 后边从 UserDefault 中提取数据还要用到
//		} else {
//			print("处理服务器返回数据失败")
//		}
//	}
//	task.resume()
//}

/// 后续用户请求数据时, 将 SessionID 放在 HTTP 头部进行请求; 同时我们可以 switch response 的状态执行不同的逻辑;
//func UserData() {
//	// 同样根据 URL 来配置请求;
//	let url = URL(string: "http://127.0.01:8080/users/all")!
//	var request = URLRequest(url: url)
//	request.httpMethod = "GET"
//	// 从 UserDefault 中提取数据, 放在 HTTPHeader 中;
//	if let sessionID = UserDefaults.standard.string(forKey: "sessionID") {
//		request.setValue(sessionID, forHTTPHeaderField: "vapor-session")
//	}
//	
//	// 请求配置完成, 现在准备发送; 发送是异步操作, 需要在 completionHandler 中处理发送后服务器的返回逻辑;
//	let task = URLSession.shared.dataTask(with: request) { data, response, error in
//		guard
//			let data = data,
//			error == nil
//		else {
//			return
//		}
//		// 根据相应的不同执行不同的 UI 逻辑;
//		if let httpResponse = response as? HTTPURLResponse {
//			switch httpResponse.statusCode {
//				case 200:
//					if
//						let json = try? JSONSerialization.jsonObject(with: data) {
//						print("获得了用户数据")
//					}
//				case 401:
//					print("重新导航到登录页面")
//				default:
//					print("获取状态码失败")
//			}
//		}
//	}
//	task.resume()
//}
