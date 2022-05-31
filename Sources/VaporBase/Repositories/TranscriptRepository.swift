// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor
import Fluent

protocol TranscriptRepository {
    func all() -> EventLoopFuture<[Transcript]>
    func forUser(_ user: User) throws -> QueryBuilder<Transcript>
}

struct DatabaseTranscriptRepository: TranscriptRepository {
    let database: Database
    func all() -> EventLoopFuture<[Transcript]> {
        return Transcript.query(on: database).all()
    }
    
    func forUser(_ user: User) throws -> QueryBuilder<Transcript> {
        try Transcript.query(on: database).filter(\.$user.$id == user.requireID())
    }
}

struct TranscriptRepositoryFactory {
    var make: ((Request) -> TranscriptRepository)?
    mutating func use(_ make: @escaping ((Request) -> TranscriptRepository)) {
        self.make = make
    }
}

extension Application {
    private struct TranscriptRepositoryKey: StorageKey {
        typealias Value = TranscriptRepositoryFactory
    }

    var transcripts: TranscriptRepositoryFactory {
        get {
            self.storage[TranscriptRepositoryKey.self] ?? .init()
        }
        set {
            self.storage[TranscriptRepositoryKey.self] = newValue
        }
    }
}

extension Request {
    var transcripts: TranscriptRepository {
        self.application.transcripts.make!(self)
    }
}
