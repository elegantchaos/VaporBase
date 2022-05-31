// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent

struct SimpleMigration<Base: Model>: Fluent.Migration {
    let name: String
    let prepareSchema: (SchemaBuilder) -> EventLoopFuture<Void>
    let revertSchema: (SchemaBuilder) -> EventLoopFuture<Void>

    internal init(_ name: String, for: Base.Type, prepare: @escaping (SchemaBuilder) -> EventLoopFuture<Void>, revert: @escaping (SchemaBuilder) -> EventLoopFuture<Void>) {
        self.name = name
        self.prepareSchema = prepare
        self.revertSchema = revert
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        prepareSchema(database.schema(Base.schema))
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        revertSchema(database.schema(Base.schema))
    }
}
