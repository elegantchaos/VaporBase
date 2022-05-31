// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/05/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

struct LoginRequest: Content {
    let email: String
    let password: String
    
    func findUser(with request: Request) async throws -> User {
        guard let user = try await User.query(on: request.db).filter(\.$email == email).first() else {
            throw AuthenticationError.invalidEmailOrPassword
        }
        
        return user
    }
    
    func verifyUser(_ user: User, request: Request) async throws -> User {
        guard try await request.password.async.verify(password, created: user.passwordHash).get() else {
            throw AuthenticationError.invalidEmailOrPassword
        }
        
        return user
    }
}

extension LoginRequest: Validatable {
    static func decode(from req: Request) throws -> LoginRequest {
        try LoginRequest.validate(content: req)
        return try req.content.decode(LoginRequest.self)
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}
