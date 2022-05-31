// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

extension Request {
    func redirect(to component: PathComponent) -> Response {
        redirect(to: "/\(component)")
    }
    
    func redirectFuture(to component: PathComponent) -> EventLoopFuture<Response> {
        eventLoop.makeSucceededFuture(redirect(to: component))
    }
}
