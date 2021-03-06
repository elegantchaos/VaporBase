// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import FluentSQL
import Vapor

extension User {
    static var createMigration: Fluent.Migration {
        SimpleMigration("CreateUser", for: self) { schema in
            return schema
                .id()
                .field(.name, .string, .required)
                .field(.email, .string, .required)
                .field(.passwordHash, .string, .required)
                .field(.roles, .string, .required)
                .field(.verification, .string, .required)
                .unique(on: .email)
                .create()

        } revert: { schema in
            schema.delete()
        }
    }
}
