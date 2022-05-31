import Vapor
import VaporBase

class TestSite: VaporBaseSite {
    var name: String { "Test "}
    var database: String { "vaporbasetest" }
}

let site = TestSite()
try site.run()
