// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor
import Fluent

struct VerifyPage: LeafPage {
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
    
    func meta(for user: User?) -> PageMetadata {
        PageMetadata("Verify Email", description: "Verification Page")
    }


    /// Data sent back by form submission.
    struct FormData: Content, Validatable {
        let code: String
        
        init(from req: Request) throws {
            try Self.validate(content: req)
            self = try req.content.decode(Self.self)
        }
        
        static func validations(_ validations: inout Validations) {
            //            validations.add("email", as: String.self, is: .)
            //            validations.addPasswordValidations(allowEmpty: false)
        }
    }

}

