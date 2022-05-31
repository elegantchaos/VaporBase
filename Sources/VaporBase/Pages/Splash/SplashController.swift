// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/10/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

extension PathComponent {
    static let splash: PathComponent = "splash"
}

struct SplashController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.splash, use: withUser(handleGetSplash))
    }

    func handleGetSplash(_ req: Request, user: User?) async throws -> Response {
        return try await req.render(SplashPage(), user: user)
    }
}


