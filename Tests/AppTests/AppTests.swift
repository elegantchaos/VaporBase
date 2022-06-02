@testable import VaporBase
import XCTVapor

final class AppTests: XCTestCase {
    func testHelloWorld() throws {
        let app = Application(.testing)
        let site = SiteConfiguration(name: "Test", database: "vaporbasetest")
        defer { app.shutdown() }
        
        try configure(app, site: site)

        try app.test(.GET, "/") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
}
