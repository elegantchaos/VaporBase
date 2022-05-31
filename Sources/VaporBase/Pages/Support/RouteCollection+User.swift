// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

extension RouteCollection {
    func withUser(req: Request, perform: @escaping (Request, User?) -> EventLoopFuture<Response>) throws -> EventLoopFuture<Response> {
        let token = req.auth.get(Token.self)
        if let token = token {
            return token.$user.get(on: req.db)
                .flatMap { user in perform(req, user) }
        } else {
            return perform(req, nil)
        }
    }
    
    func withUser(_ perform: @escaping (Request, User?) -> EventLoopFuture<Response>) -> (Request) throws -> EventLoopFuture<Response> {
        return { req in
            try withUser(req: req, perform: perform)
        }
    }

    func requireUser(req: Request, perform: @escaping (Request, User) throws -> EventLoopFuture<Response>) throws -> EventLoopFuture<Response> {
        let token = req.auth.get(Token.self)
        if let token = token {
            return token.$user.get(on: req.db)
                .flatMapThrowing { user in try perform(req, user) }
                .flatMap { future in future }
        } else {
            return req.eventLoop.makeSucceededFuture(req.redirect(to: .login))
        }
    }
    
    func requireUser(_ perform: @escaping (Request, User) throws -> EventLoopFuture<Response>) -> (Request) throws -> EventLoopFuture<Response> {
        return { req in
            try requireUser(req: req, perform: perform)
        }
    }

}
