// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor
import Fluent


extension PathComponent {
    static let register: PathComponent = "register"
}

struct RegistrationController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(.register, use: handleGetRegister)
        routes.post(.register, use: handlePostRegister)
    }
    
    func handleGetRegister(req: Request) async throws -> Response {
        return try await req.render(RegisterPage())
    }
    
    func handlePostRegister(_ req: Request) async throws -> Response {
        let form = try RegisterPage.FormData(from: req)
        let hash = try await form.hash(with: req)
        let user = User(name: form.name, email: form.email, passwordHash: hash)
        do {
            try await user.create(on: req.db)
        } catch let error as DatabaseError where error.isConstraintFailure  {
            throw AuthenticationError.emailAlreadyExists
        }
        
        return req.redirect(to: .login)
    }
    
}

