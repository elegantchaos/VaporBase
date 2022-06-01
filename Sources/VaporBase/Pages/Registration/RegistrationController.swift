// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/04/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Mailgun
import Vapor

extension PathComponent {
    static let register: PathComponent = "register"
    static let mailtest: PathComponent = "mailtest"
}

struct RegistrationController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(.register, use: handleGetRegister)
        routes.post(.register, use: handlePostRegister)
        routes.get(.mailtest, use: handleGetMailTest)
    }
    
    func handleGetRegister(req: Request) async throws -> Response {
        return try await req.render(RegisterPage())
    }
    
    func handlePostRegister(_ req: Request) async throws -> Response {
        let form = try RegisterPage.FormData(from: req)
        let hash = try await form.hash(with: req)
        let user = User(name: form.name, email: form.email, passwordHash: hash)
        do {
            try await user.create(on: req.db)
            
        } catch let error as DatabaseError where error.isConstraintFailure  {
            throw AuthenticationError.emailAlreadyExists
        }

        do {
        let message = MailgunMessage(
            from: "postmaster@mailgun.elegantchaos.com",
            to: "sam@elegantchaos.com",
            subject: "Verify Your Email Address",
            text: "Please verify your email address.",
            html: "<h1>Please verify your email address.</h1>"
        )
        
        let response = try await req.mailgun().send(message).get()
        } catch {
            print("error sending email \(error)")
        }
        
        return req.redirect(to: .login)
    }
    
    func handleGetMailTest(_ req: Request) async throws -> Response {
        do {
            let message = MailgunMessage(
                from: "postmaster@mailgun.elegantchaos.com",
                to: "sam@elegantchaos.com",
                subject: "Verify Your Email Address",
                text: "Please verify your email address.",
                html: "<h1>Please verify your email address.</h1>"
            )
            
            let response = try await req.mailgun().send(message).get()
        } catch {
            print("error sending email \(error)")
        }

        return req.redirect(to: .adminIndex)
    }
}

