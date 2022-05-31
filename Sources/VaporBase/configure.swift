import Coercion
import Foundation
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf
import LeafKit

// configures your application

public func configure(_ app: Application, site: SiteConfiguration) throws {

    if let databaseURL = Environment.get("DATABASE_URL"), var postgresConfig = PostgresConfiguration(url: databaseURL) {
        var configuration: TLSConfiguration = .makeClientConfiguration()
        configuration.certificateVerification = .none
        postgresConfig.tlsConfiguration = configuration
        app.databases.use(.postgres(
            configuration: postgresConfig
        ), as: .psql)
    } else {
        app.databases.use(.postgres(hostname: "localhost", username: "vapor", password: "vapor", database: site.database), as: .psql)
    }
    app.sessions.use(.fluent)
    
    setupMigrations(app)
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))     // serve files from /Public folder

    // Configure Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    let path = Bundle.module.url(forResource: "Views", withExtension: nil)!.path
    print("VaporBase built-in views path is: \(path)")
    let source = NIOLeafFiles(fileio: app.fileio,
                              limits: [.toSandbox, .requireExtensions], // Heroku bundle files are inside `.swift-bin`, which can be mistaken for being invisible
                              sandboxDirectory: path,
                              viewDirectory: path)

    let sources = app.leaf.sources
    try sources.register(source: "builtin", using: source, searchable: true)
    app.leaf.sources = sources

    // register routes
    try routes(app)
    
    app.users.use { req in DatabaseUserRepository(database: req.db) }
    app.tokens.use { req in DatabaseTokenRepository(database: req.db) }
    app.transcripts.use { req in DatabaseTranscriptRepository(database: req.db) }

    app.site = site
    
    if Environment.get("OPEN_LOCALLY")?.asBool ?? false {
        app.openLocally()
    }
    
    try app.autoMigrate().wait()
}

fileprivate func setupMigrations(_ app: Application) {
    app.migrations.add(User.createMigration)
    app.migrations.add(Token.createMigration)
    app.migrations.add(SessionRecord.migration)
    app.migrations.add(User.addHistoryMigration)
    app.migrations.add(Transcript.createMigration)
    app.migrations.add(User.makeEmailUnique)
    app.migrations.add(User.addUserRoles)
}


public struct SiteConfiguration {
    let name: String
    let database: String

    public init(name: String, database: String) {
        self.name = name
        self.database = database
    }
}

struct SiteConfigurationKey: StorageKey {
    typealias Value = SiteConfiguration
}


extension Application {
    var site: SiteConfiguration {
        get {
            self.storage[SiteConfigurationKey.self]!
        }
        
        set {
            self.storage[SiteConfigurationKey.self] = newValue
        }
    }
}

#if canImport(AppKit)
import AppKit
#endif

public extension Application {
    func openLocally() {
        #if canImport(AppKit)
        let configuration = http.server.configuration
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
            NSWorkspace.shared.open(URL(string: "http://\(configuration.hostname):\(configuration.port)/")!)
        }
        #endif
    }
}
