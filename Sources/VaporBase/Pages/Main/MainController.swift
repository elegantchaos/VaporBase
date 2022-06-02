// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct InputRequest: Content {
    let command: String
}

extension PathComponent {
    static let help: PathComponent = "help"
    static let main: PathComponent = ""
}

struct MainController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.help, use: requireUser(handleGetHelp))
        routes.get(.main, use: optionalUser(handleGetMain))
    }

    func handleGetHelp(_ req: Request, user: User) async throws -> Response {
        return try await req.render(HelpPage(), user: user)
    }

    func handleGetMain(_ req: Request, user: User?) async throws -> Response {
        let site = req.application.site
        return try await req.render(MainPage(user: user, site: site), user: user)
    }
}

