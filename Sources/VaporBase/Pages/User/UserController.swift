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
    
    func handleUpdateSettings(_ req: Request, for user: User) throws -> EventLoopFuture<Response> {
        let formData = try ProfilePage.FormData(from: req)
        user.name = formData.name
        user.email = formData.email
        if !formData.password.isEmpty, let newHash = try? req.password.sync.hash(formData.password) {
            user.passwordHash = newHash
        }
        return user.save(on: req.db)
            .thenRedirect(with: req, to: .main)
    }

    func handleLogout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        req.session.destroy()
        return req.redirect(to: .login)
    }

    func renderProfilePage(_ req: Request, for user: User) -> EventLoopFuture<Response> {
        let rendered = req.render(ProfilePage(user: user), user: user)

        return req
            .users
            .all()
            .flatMap({
                // if this is the only user, ensure that they have admin rights
                if ($0.count == 1) && !user.isAdmin {
                    user.addRole("admin")
                    return user
                        .save(on: req.db)
                        .flatMap({ rendered })
                } else {
                    return rendered
                }
            })
    }
}
