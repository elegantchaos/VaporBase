// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import FluentSQL
import Vapor

extension User {
    static var addHistoryMigration: Fluent.Migration {
        SimpleMigration("AddUserHistory", for: self) { schema in
            let defaultValue = SQLColumnConstraintAlgorithm.default("")
            return schema
                .field(.history, .string, .sql(defaultValue))
                .update()
        } revert: { schema in
            schema
                .deleteField(.history)
                .update()
        }
    }
}
