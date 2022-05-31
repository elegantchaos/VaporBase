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
        routes.get(.adminIndex, use: requireAdmin(handleGetAdminIndex))
        routes.get(.adminTokens, use: requireAdmin(handleGetAdminTokens))
        routes.get(.adminSessions, use: requireAdmin(handleGetAdminSessions))
        routes.get(.adminUser, .userParameter, use: requireAdmin(handleGetAdminUser))
        routes.post(.adminUser, .userParameter, use: requireAdmin(handlePostAdminUser))
    }
    
    func handleGetAdminIndex(_ req: Request, for loggedInUser: User) async throws -> Response {
        let users = try await req.users.all()
        let page = AdminIndexPage(users: users)
        return try await req.render(page, user: loggedInUser)
    }

    func handleGetAdminTokens(_ req: Request, for loggedInUser: User) async throws -> Response {
        let tokens = try await Token.query(on: req.db).with(\.$user).all()
        let page = AdminTokenPage(tokens: tokens)
        return try await req.render(page, user: loggedInUser)
    }

    func handleGetAdminSessions(_ req: Request, for loggedInUser: User) async throws -> Response {
        let sessions = try await SessionRecord.query(on: req.db).all()
        let page = AdminSessionPage(sessions: sessions)
        return try await req.render(page, user: loggedInUser)
    }

    func handleGetAdminUser(_ req: Request, for loggedInUser: User) async throws -> Response {
        let userID = try req.parameters.require("user", as: UUID.self)
        guard let user = try await User.query(on: req.db).filter(\.$id == userID).first() else {
            throw AdminError.unknownUser
        }

        let page = AdminUserPage(user: user)
        return try await req.render(page, user: loggedInUser)
    }

    func handlePostAdminUser(_ req: Request, for loggedInUser: User) async throws -> Response {
        let response = try AdminUserPage.FormData(from: req)

        let userID = try req.parameters.require("user", as: UUID.self)
        guard let user = try await User.query(on: req.db).filter(\.$id == userID).first() else {
            throw AdminError.unknownUser
        }
        
        user.name = response.name
        user.email = response.email
        user.roles = response.roles
        if let newHash = response.updatedHash(with: req) {
            user.passwordHash = newHash
        }
                
        try await user.save(on: req.db)
        return req.redirect(to: .adminIndex)
    }
}
