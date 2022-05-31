import Vapor
import VaporBase

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
let site = SiteConfiguration(name: "Test", database: "vaporbasetest")
defer { app.shutdown() }
try configure(app, site: site)

try app.run()
