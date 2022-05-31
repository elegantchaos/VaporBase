// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension PathComponent {
    static let login: PathComponent = "login"
}

struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.login, use: renderLogin)
        if let app = routes as? Application {
            let sessionEnabled = routes.grouped(
                SessionsMiddleware(session: app.sessions.driver)
            )
            sessionEnabled.post(.login, use: handleLogin)
        }
    }
    
    func renderLogin(_ req: Request) async throws -> Response {
        let page = LoginPage()
        return try await req.render(page)
    }
    
    func handleLogin(_ req: Request) async throws -> Response {
        do {
            let login = try LoginRequest.decode(from: req)
            let user = try await login.findUser(with: req)
            
            do {
                let verified = try await login.verifyUser(user, request: req)
                let tokens = try req.tokens.forUser(verified)
                try await tokens.delete()
                
                let newToken = try user.generateToken()
                try await newToken.create(on: req.db)
                req.session.authenticate(newToken)
                return req.redirect(to: .main)
            } catch {
                return try await req.render(LoginPage(request: login), error: error)
            }

        } catch {
            return try await req.render(LoginPage())
        }
        
    }
}
