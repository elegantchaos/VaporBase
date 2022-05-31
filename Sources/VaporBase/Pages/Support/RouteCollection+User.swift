// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

extension RouteCollection {
    func withUser(req: Request, perform: @escaping (Request, User?) async -> Response) async throws -> Response {
        let token = req.auth.get(Token.self)
        let user: User?
        if let token = token {
            user = try await token.$user.get(on: req.db)
        } else {
            user = nil
        }

        return await perform(req, user)
    }
    
    func withUser(_ perform: @escaping (Request, User?) async -> Response) -> (Request) async throws -> Response {
        return { req in
            try await withUser(req: req, perform: perform)
        }
    }

    func requireUser(req: Request, perform: @escaping (Request, User) async throws -> Response) async throws -> Response {
        let token = req.auth.get(Token.self)
        if let token = token {
            let user = try await token.$user.get(on: req.db)
            return try await perform(req, user)
        } else {
            return req.redirect(to: .login)
        }
    }
    
    func requireUser(_ perform: @escaping (Request, User) async throws -> Response) -> (Request) async throws -> Response {
        return { req in
            try await requireUser(req: req, perform: perform)
        }
    }

    func requireAdmin(_ perform: @escaping (Request, User) async throws -> Response) -> (Request) async throws -> Response {
        return { req in
            try await requireUser(req: req) { req, user in
                guard user.isAdmin else {
                    throw AdminError.notAdmin
                }
                
                return try await perform(req, user)
            }
        }
    }

}
