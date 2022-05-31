// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

enum AdminError: String, DebuggableError {
    case unknownUser
    case notAdmin
    
    var identifier: String {
        rawValue
    }
    
    var reason: String {
        rawValue
    }
    
}




extension PathComponent {
    static let adminIndex: PathComponent = "admin"
    static let adminUser: PathComponent = "admin-user"
    static let adminTokens: PathComponent = "admin-tokens"
    static let adminSessions: PathComponent = "admin-sessions"
    static let userParameter: PathComponent = ":user"
}

struct AdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.adminIndex, use: requireUser(handleGetAdminIndex))
        routes.get(.adminTokens, use: requireUser(handleGetAdminTokens))
        routes.get(.adminSessions, use: requireUser(handleGetAdminSessions))
        routes.get(.adminUser, .userParameter, use: requireUser(handleGetAdminUser))
        routes.post(.adminUser, .userParameter, use: requireUser(handlePostAdminUser))
    }
    
    func unpack(_ data: (([SessionRecord], [User]), [Transcript])) -> ([SessionRecord], [User], [Transcript]) {
        let (tsu, transcripts) = data
        let (sessions, users) = tsu
        return (sessions, users, transcripts)
    }
    
    func handleGetAdminIndex(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }
            
        return req.users.all()
            .flatMap { users in
                let page = AdminIndexPage(users: users)
                return req.render(page, user: loggedInUser)
            }
    }

    func handleGetAdminTokens(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }
            
        return Token.query(on: req.db).with(\.$user).all()
            .flatMap { tokens in
                let page = AdminTokenPage(tokens: tokens)
                return req.render(page, user: loggedInUser)
            }
    }

    func handleGetAdminSessions(_ req: Request, for loggedInUser: User) -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }
            
        return SessionRecord.query(on: req.db).all()
            .flatMap { sessions in
                let page = AdminSessionPage(sessions: sessions)
                return req.render(page, user: loggedInUser)
            }
    }

    func handleGetAdminUser(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }

        let userID = try req.parameters.require("user", as: UUID.self)
        let transcripts = Transcript
            .query(on: req.db)
            .with(\.$user)
            .filter(\.$user.$id == userID)
            .all()

        let user = User.query(on: req.db).filter(\.$id == userID).first()
        return user
            .unwrap(or: AdminError.unknownUser)
            .and(transcripts)
            .flatMap { (user, transcripts) in
                req.render(AdminUserPage(user: user, transcripts: transcripts), user: loggedInUser) }
    }

    func handlePostAdminUser(_ req: Request, for loggedInUser: User) throws -> EventLoopFuture<Response> {
        guard loggedInUser.isAdmin else {
            return req.eventLoop.makeFailedFuture(AdminError.notAdmin)
        }

        let response = try AdminUserPage.FormData(from: req)

        let userID = try req.parameters.require("user", as: UUID.self)
        let user = User.query(on: req.db).filter(\.$id == userID).first()
        return user
            .unwrap(or: AdminError.unknownUser)
            .map { (updatedUser: User) -> EventLoopFuture<Void> in
                updatedUser.name = response.name
                updatedUser.email = response.email
                updatedUser.roles = response.roles
                if let newHash = response.updatedHash(with: req) {
                    updatedUser.passwordHash = newHash
                }
                
                return updatedUser.save(on: req.db)
            }
            .thenRedirect(with: req, to: .adminIndex)
    }
}
