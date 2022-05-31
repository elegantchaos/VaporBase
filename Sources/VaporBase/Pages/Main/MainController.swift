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
        routes.get(.main, use: withUser(handleGetMain))
    }

    func handleGetHelp(_ req: Request, user: User) -> EventLoopFuture<Response> {
        return req.render(HelpPage(), user: user)
    }

    func handleGetMain(_ req: Request, user: User?) -> EventLoopFuture<Response> {
        let site = req.application.site
        return req.render(MainPage(user: user, site: site), user: user)
    }
}

