// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension PathComponent {
    static let register: PathComponent = "register"
    static let login: PathComponent = "login"
}

struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.register, use: handleGetRegister)
        routes.post(.register, use: handlePostRegister)
        routes.get(.login, use: handleGetLogin)
        if let app = routes as? Application {
            let sessionEnabled = routes.grouped(
                SessionsMiddleware(session: app.sessions.driver)
            )
            sessionEnabled.post(.login, use: handlePostLogin)
        }
    }
    
    func handleGetRegister(req: Request) async throws -> Response {
        return try await req.render(RegisterPage())
    }
    
    func handlePostRegister(_ req: Request) async throws -> Response {
        let form = try RegisterPage.FormData(from: req)
        let hash = try await form.hash(with: req)
        let user = User(name: form.name, email: form.email, passwordHash: hash)
        let users = try await req.users.all()

        if users.count == 0 {
            user.addRole(.adminRole)
            req.logger.debug("First user promoted to admin.")
        }

        do {
            try await user.create(on: req.db)
        } catch let error as DatabaseError where error.isConstraintFailure  {
            throw AuthenticationError.emailAlreadyExists
        }
        
        return req.redirect(to: .login)
    }
    
    
    func handleGetLogin(_ req: Request) async throws -> Response {
        let page = LoginPage()
        return try await req.render(page)
    }
    
    func handlePostLogin(_ req: Request) async throws -> Response {
        do {
            let login = try LoginRequest.decode(from: req)
            let user = try await login.findUser(with: req)
            
            do {
                let authorized = try await login.authenticateUser(user, request: req)
                let tokens = try req.tokens.forUser(authorized)
                try await tokens.delete()
                
                let newToken = try user.generateToken()
                try await newToken.create(on: req.db)
                req.session.authenticate(newToken)
                
                return req.redirect(to: user.emailIsVerified ? .main : .verify)
            } catch {
                return try await req.render(LoginPage(request: login), error: error)
            }

        } catch {
            return try await req.render(LoginPage())
        }
        
    }

}
