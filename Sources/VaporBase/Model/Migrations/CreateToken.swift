// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent

extension Token {
    static var createMigration: Fluent.Migration {
        SimpleMigration("CreateToken", for: self) { schema in
            schema
                .id()
                .field(.value, .string, .required)
                .field(.user, .uuid, .required, .references("users", "id"))
                .unique(on: .value)
                .create()
        } revert: { schema in
            schema
                .delete()
        }
    }
}
