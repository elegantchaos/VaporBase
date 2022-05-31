// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

extension RouteCollection {
    /// Extract the authorised user, then perform some code.
    /// The user passed to the code is optional, and can be nil if the session is not authorised.
    func performWithUser(req: Request, code: @escaping (Request, User?) async throws -> Response) async throws -> Response {
        let token = req.auth.get(Token.self)
        let user: User?
        if let token = token {
            user = try await token.$user.get(on: req.db)
        } else {
            user = nil
        }

        return try await code(req, user)
    }

    /// Return a closure that extracts the authorised user, then perform some code.
    /// The user passed to the code is optional, and can be nil if the session is not authorised.
    func withUser(_ perform: @escaping (Request, User?) async throws -> Response) -> (Request) async throws -> Response {
        return { req in
            try await performWithUser(req: req, code: perform)
        }
    }

    /// Extract the authorised user, then perform some code.
    /// The user is required, and we throw an error if the session is not authorised.
    func performRequiringUser(req: Request, code: @escaping (Request, User) async throws -> Response) async throws -> Response {
        let token = req.auth.get(Token.self)
        if let token = token {
            let user = try await token.$user.get(on: req.db)
            return try await code(req, user)
        } else {
            return req.redirect(to: .login)
        }
    }
    
    /// Return a closure that extracts the authorised user, then perform some code.
    /// The user is required, and we throw an error if the session is not authorised.
    func requireUser(_ perform: @escaping (Request, User) async throws -> Response) -> (Request) async throws -> Response {
        return { req in
            try await performRequiringUser(req: req, code: perform)
        }
    }

    /// Return a closure that extracts the authorised user, checks if it is an admin, then perform some code.
    /// The user is required to be an admin, and we throw an error if the session is not authorised, or the user is non-admin.
    func requireAdmin(_ perform: @escaping (Request, User) async throws -> Response) -> (Request) async throws -> Response {
        return { req in
            try await performRequiringUser(req: req) { req, user in
                guard user.isAdmin else {
                    throw AdminError.notAdmin
                }
                
                return try await perform(req, user)
            }
        }
    }

}
