// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Vapor

protocol PasswordFormData: Codable, Validatable {
    var password: String { get }
    var confirm: String { get }
    
    func validatePasswordsMatch() throws
    func hash(with req: Request) -> EventLoopFuture<String>
}

extension PasswordFormData {
    func hash(with req: Request) -> EventLoopFuture<String> {
        return req.password.async.hash(password)
    }
    
    func updatedHash(with req: Request) -> String? {
        guard !password.isEmpty else { return nil }
        return try? req.password.sync.hash(password)
    }
    
    func validatePasswordsMatch() throws {
        guard password == confirm else {
            throw AuthenticationError.passwordsDontMatch
        }
    }
}

extension Validations {
    mutating func addPasswordValidations(allowEmpty: Bool) {
        if allowEmpty {
            add("password", as: String.self, is: .count(4...) || .empty)
        } else {
            add("password", as: String.self, is: .count(4...))
        }
    }
}
