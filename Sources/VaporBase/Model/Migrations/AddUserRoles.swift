// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/10/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import FluentSQL
import Vapor

extension User {
    static var addUserRoles: Fluent.Migration {
        SimpleMigration("AddUserRoles", for: self) { schema in
            let defaultValue = SQLColumnConstraintAlgorithm.default("")
            return schema
                .field(.roles, .string, .sql(defaultValue))
                .update()
        } revert: { schema in
            schema
                .deleteField(.roles)
                .update()
        }
    }
}

