// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor
import Fluent

struct RegisterPage: LeafPage {
    
    func meta(for user: User?) -> PageMetadata {
        PageMetadata("Register", description: "Registration Page")
    }

    /// Data sent back by form submission.
    struct Form: Content, PasswordFormData {
        let name: String
        let email: String
        let password: String
        let confirm: String
        
        func hash(with req: Request) async throws -> String {
            return try await req.password.async.hash(password)
        }
        
        init(from req: Request) throws {
            try Self.validate(content: req)
            self = try req.content.decode(Self.self)
            try validatePasswordsMatch()
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
            validations.addPasswordValidations(allowEmpty: false)
        }
    }

}

