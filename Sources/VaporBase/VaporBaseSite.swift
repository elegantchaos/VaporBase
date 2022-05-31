import Coercion
import Foundation
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf
import LeafKit

#if canImport(AppKit)
import AppKit
#endif

open class VaporBaseSite {
    open var name: String { fatalError("subclass should override this ") }
    open var database: String { fatalError("subclass should override this ") }
    
    public init() {
    }
    
    /// Setup and run the server.
    public func run() throws {

        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }
        try configure(app)
        
        if Environment.get("OPEN_LOCALLY")?.asBool ?? false {
            openLocally(app)
        }

        try app.run()
    }
    
    /// Configure the server.
    /// This performs various default setup tasks, and calls out to various `setupSite...` configuration points,
    /// which a subclass can override to customise things.
    private func configure(_ app: Application) throws {
        setupDatabase(app)
        app.sessions.use(.fluent)
        
        setupMigrations(app)
        setupMiddleware(app)
        setupLeaf(app)
        
        try setupSources(app)
        try registerRoutes(app)
        registerRepositories(app)
        
        app.site = self
        
        try app.autoMigrate().wait()

    }
    
    private func openLocally(_ app: Application) {
#if canImport(AppKit)
        let configuration = app.http.server.configuration
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
            NSWorkspace.shared.open(URL(string: "http://\(configuration.hostname):\(configuration.port)/")!)
        }
#endif
    }

    open func setupDatabase(_ app: Application) {
        if let databaseURL = Environment.get("DATABASE_URL"), var postgresConfig = PostgresConfiguration(url: databaseURL) {
            var configuration: TLSConfiguration = .makeClientConfiguration()
            configuration.certificateVerification = .none
            postgresConfig.tlsConfiguration = configuration
            app.databases.use(.postgres(
                configuration: postgresConfig
            ), as: .psql)
        } else {
            app.databases.use(.postgres(hostname: "localhost", username: "vapor", password: "vapor", database: database), as: .psql)
        }
    }
    
    open func setupLeaf(_ app: Application) {
        app.views.use(.leaf)
        app.leaf.cache.isEnabled = app.environment.isRelease
    }
    
    open func setupMiddleware(_ app: Application) {
        setupDefaultMiddleware(app)
        setupSiteMiddleware(app)
    }
    
    open func setupSources(_ app: Application) throws {
        let sources = app.leaf.sources
        try setupSiteSources(app, sources: sources)
        try setupDefaultSources(app, sources: sources)
        app.leaf.sources = sources
    }
    
    public func setupDefaultSources(_ app: Application, sources: LeafSources) throws {
        let path = Bundle.module.url(forResource: "Views", withExtension: nil)!.path
        print("VaporBase built-in views path is: \(path)")
        let source = NIOLeafFiles(fileio: app.fileio,
                                  limits: [.toSandbox, .requireExtensions], // Heroku bundle files are inside `.swift-bin`, which can be mistaken for being invisible
                                  sandboxDirectory: path,
                                  viewDirectory: path)
        
        try sources.register(source: "builtin", using: source, searchable: true)
    }
    
    public func setupDefaultMiddleware(_ app: Application) {
        app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))     // serve files from /Public folder
    }
    
    open func registerRepositories(_ app: Application) {
        registerDefaultRepositories(app: app)
        registerSiteRespositories(app: app)
    }
    
    public func registerDefaultRepositories(app: Application) {
        app.users.use { req in DatabaseUserRepository(database: req.db) }
        app.tokens.use { req in DatabaseTokenRepository(database: req.db) }
    }
    
    private func registerRoutes(_ app: Application) throws {
        let protectedRoutes = app.grouped(
            SessionsMiddleware(session: app.sessions.driver),
            Token.sessionAuthenticator()
        )
    
        try registerDefaultRoutes(app: app, protectedRoutes: protectedRoutes)
        try registerSiteRoutes(app: app, protectedRoutes: protectedRoutes)
    }

    public func registerDefaultRoutes(app: Application, protectedRoutes: RoutesBuilder) throws {
        try app.register(collection: LoginController())
        try app.register(collection: SplashController())
        try protectedRoutes.register(collection: UserController())
        try protectedRoutes.register(collection: MainController())
        try protectedRoutes.register(collection: AdminController())
        try app.register(collection: RegistrationController())
    }
    
    open func setupMigrations(_ app: Application) {
        setupDefaultMigrations(app)
        setupSiteMigrations(app)
    }

    public func setupDefaultMigrations(_ app: Application) {
        app.migrations.add(User.createMigration)
        app.migrations.add(Token.createMigration)
        app.migrations.add(SessionRecord.migration)
    }
    

    // MARK: Customisation Points

    open func setupSiteSources(_ app: Application, sources: LeafSources) throws {
        
    }
    
    open func setupSiteMiddleware(_ app: Application) {
        
    }

    open func registerSiteRespositories(app: Application) {
        
    }

    open func registerSiteRoutes(app: Application, protectedRoutes: RoutesBuilder) throws {
    }
    
    open func setupSiteMigrations(_ app: Application) {
    }
}


struct SiteKey: StorageKey {
    typealias Value = VaporBaseSite
}


extension Application {
    var site: VaporBaseSite {
        get {
            self.storage[SiteKey.self]!
        }
        
        set {
            self.storage[SiteKey.self] = newValue
        }
    }
}
