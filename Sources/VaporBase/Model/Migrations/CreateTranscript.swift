// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent

extension Transcript {
    static var createMigration: Fluent.Migration {
        return SimpleMigration("CreateTranscript", for: self) { schema in
            schema
                .id()
                .field(.value, .string, .required)
                .field(.user, .uuid, .required, .references("users", "id"))
                .create()
        } revert: { schema in
            schema
                .delete()
        }
    }
}
