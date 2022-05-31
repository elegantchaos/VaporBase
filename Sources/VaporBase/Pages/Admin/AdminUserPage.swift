// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct AdminUserPage: LeafPage {
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func meta(for loggedInUser: User?) -> PageMetadata {
        let title: String
        let description: String

        title = "Edit User: \(user.name) (admin as \(loggedInUser!.name))"
        description = "Admin page for \(user.name)."

        return PageMetadata(title, description: description)
    }
    
    // Sent back by the UserAdminPage form
    struct FormData: PasswordFormData {
        let name: String
        let email: String
        let roles: String
        let password: String
        let confirm: String

        init(from req: Request) throws {
            try Self.validate(content: req)
            self = try req.content.decode(Self.self)
            try validatePasswordsMatch()
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
            validations.addPasswordValidations(allowEmpty: true)
        }

    }

}

