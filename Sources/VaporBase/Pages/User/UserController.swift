// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension PathComponent {
    static let settings: PathComponent = "settings"
    static let logout: PathComponent = "logout"
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.settings, use: requireUser(renderProfilePage))
        routes.post(.settings, use: requireUser(handleUpdateSettings))
        routes.get(.logout, use: handleLogout)
    }
    
    func handleUpdateSettings(_ req: Request, for user: User) async throws -> Response {
        let formData = try ProfilePage.FormData(from: req)
        user.name = formData.name
        user.email = formData.email
        if !formData.password.isEmpty, let newHash = try? await req.password.async.hash(formData.password) {
            user.passwordHash = newHash
        }
        
        try await user.save(on: req.db)
        return req.redirect(to: .main)
    }

    func handleLogout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        req.session.destroy()
        return req.redirect(to: .login)
    }

    func renderProfilePage(_ req: Request, for user: User) async throws -> Response {
        let users = try await req.users.all()

        if (users.count == 1) && !user.isAdmin {
            // if this is the only user, ensure that they have admin rights
            user.addRole("admin")
            try await user.save(on: req.db)
        }

        return try await req.render(ProfilePage(user: user), user: user)
    }
}
