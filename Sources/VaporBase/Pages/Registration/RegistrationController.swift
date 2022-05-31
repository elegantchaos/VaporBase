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
    
    func handleGetRegister(req: Request) throws -> EventLoopFuture<Response> {
        return req.render(RegisterPage())
    }
    
    func handlePostRegister(_ req: Request) throws -> EventLoopFuture<Response> {
        let form = try RegisterPage.FormData(from: req)
        
        return form.hash(with: req)
            .withNewUser(using: form, with: req)
            .create(on: req.db)
            .translatingError(to: AuthenticationError.emailAlreadyExists, if: { (error: DatabaseError) in error.isConstraintFailure })
            .redirect(with: req, to: .login)
    }
    
}

