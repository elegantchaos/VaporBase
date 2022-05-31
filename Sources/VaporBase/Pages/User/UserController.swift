// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension PathComponent {
    static let profile: PathComponent = "profile"
    static let logout: PathComponent = "logout"
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.profile, use: requireUser(handleGetProfile))
        routes.post(.profile, use: requireUser(handlePostProfile))
        routes.get(.logout, use: handleGetLogout)
    }
    
    func handlePostProfile(_ req: Request, for user: User) async throws -> Response {
        let formData = try ProfilePage.FormData(from: req)
        user.name = formData.name
        user.email = formData.email
        if !formData.password.isEmpty, let newHash = try? await req.password.async.hash(formData.password) {
            user.passwordHash = newHash
        }
        
        try await user.save(on: req.db)
        return req.redirect(to: .main)
    }

    func handleGetLogout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        req.session.destroy()
        return req.redirect(to: .login)
    }

    func handleGetProfile(_ req: Request, for user: User) async throws -> Response {
        let users = try await req.users.all()

        if (users.count == 1) && !user.isAdmin {
            // if this is the only user, ensure that they have admin rights
            user.addRole("admin")
            try await user.save(on: req.db)
        }

        return try await req.render(ProfilePage(user: user), user: user)
    }
}
