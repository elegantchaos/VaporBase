// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Vapor

struct ProfilePage: LeafPage {
    init(user: User?) {
    }
    
    func meta(for user: User?) -> PageMetadata {
        let title: String
        let description: String

        if let user = user {
            title = "Profile: \(user.name)"
            description = "Profile page for \(user.name)."
        } else {
            title = "Not Logged In"
            description = "Not Logged In"
        }
        return PageMetadata(title, description: description)
    }
    
    struct FormData: PasswordFormData {
        let name: String
        let email: String
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
