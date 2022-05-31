// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

fileprivate let isSitePublished = Environment.get("PUBLISHED") == "true"

protocol LeafPage: Codable {
    func meta(for user: User?) -> PageMetadata
}

extension LeafPage {
}

struct Site: Codable {
    let title: String
}

struct RenderContext<Page>: Codable where Page: LeafPage {
    internal init(page: Page, user: User?, error: String?, site: VaporBaseSite) {
        let file = String(describing: Page.self)

        self.site = Site(title: site.name)
        self.meta = page.meta(for: user)
        self.file = file
        self.page = page
        self.user = user
        self.error = error
        self.isAdmin = user?.isAdmin ?? false
        self.isPublished = isSitePublished
    }
    
    let site: Site
    let meta: PageMetadata
    let file: String
    let page: Page
    let user: User?
    let error: String?
    let isAdmin: Bool
    let isPublished: Bool
}

extension Request {
    func render<T>(_ page: T, user: User? = nil, error: Error? = nil) -> EventLoopFuture<Response> where T: LeafPage {
        let context = RenderContext(page: page, user: user, error: error?.localizedDescription, site: application.site)
        return view.render(context.file, context).encodeResponse(for: self)
    }
}
