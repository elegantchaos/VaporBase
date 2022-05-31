// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor
import Fluent

public extension EventLoopFuture {
    func then<NewValue>(file: StaticString = #file, line: UInt = #line, _ callback: @escaping (Value) -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        flatMap(callback)
    }

    func redirect(with request: Request, to: PathComponent) -> EventLoopFuture<Response> {
        map { _ in request.redirect(to: to) }
    }

    func thenRedirect(with request: Request, to: PathComponent) -> EventLoopFuture<Response> {
        map { _ in request.redirect(to: to) }
    }

    func translatingError<ErrorType>(to error: Error, if condition: @escaping (ErrorType) -> Bool) -> EventLoopFuture<Value> {
        flatMapErrorThrowing {
            if let dbError = $0 as? ErrorType, condition(dbError) {
                throw error
            }
            throw $0
        }
    }

}

public extension EventLoopFuture {
    func withValue<T: Model>(_ item: T) -> EventLoopFuture<T> {
        map { _ in item }
    }
}

public extension EventLoopFuture where Value: Model {
    func create(on db: Database) -> EventLoopFuture<Void> {
        flatMap { item in item.create(on: db) }
    }
}

extension EventLoopFuture where Value == String {
    func withNewUser(using registration: RegisterPage.FormData, with req: Request) -> EventLoopFuture<User>  {
        flatMapThrowing { hash in User(name: registration.name, email: registration.email, passwordHash: hash) }
            .translatingError(to: AuthenticationError.emailAlreadyExists, if: { (error: DatabaseError) in error.isConstraintFailure })
    }
    
}
