// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Mailgun
import Vapor

extension PathComponent {
    static let profile: PathComponent = "profile"
    static let verify: PathComponent = "verify"
    static let logout: PathComponent = "logout"
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.profile, use: requireUser(handleGetProfile))
        routes.post(.profile, use: requireUser(handlePostProfile))
        routes.get(.verify, use: requireUser(requireVerified: false, handleGetVerify))
        routes.post(.verify, use: requireUser(requireVerified: false, handlePostVerify))
        routes.get(.logout, use: handleGetLogout)
    }
    
    func handleGetProfile(_ req: Request, for user: User) async throws -> Response {
        return try await req.render(ProfilePage(user: user), user: user)
    }
    
    func handlePostProfile(_ req: Request, for user: User) async throws -> Response {
        let formData = try ProfilePage.FormData(from: req)
        user.name = formData.name
        user.email = formData.email
        if !formData.password.isEmpty, let newHash = try? await req.password.async.hash(formData.password) {
            user.passwordHash = newHash
        }
        
        try await user.save(on: req.db)
        return req.redirect(to: .main)
    }
    
    func handleGetVerify(_ req: Request, user: User) async throws -> Response {
        guard !user.emailIsVerified else {
            return req.redirect(to: .main)
        }
        
        if user.verification.isEmpty {
            // generate a new code and send a verification email
            let code = UUID().uuidString
            user.verification = code
            try await user.save(on: req.db)
            await sendVerificationMessage(req, user: user)
        }
        
        let message = "A verification code was sent to \(user.email). Please enter the code below."
        return try await req.render(VerifyPage(message: message))
    }
    
    func handlePostVerify(_ req: Request, user: User) async throws -> Response {
        guard !user.emailIsVerified else {
            return req.redirect(to: .main)
        }
        
        let form = try VerifyPage.FormData(from: req)
        if user.verification == form.code {
            user.verification = "verified"
            try await user.save(on: req.db)
            return req.redirect(to: .main)
        }
        
        let message = "The code \(form.code) didn't match. Please re-enter it."
        return try await req.render(VerifyPage(message: message))
    }

    func handleGetLogout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        req.session.destroy()
        return req.redirect(to: .login)
    }

    func sendVerificationMessage(_ req: Request, user: User) async {
        let configuration = req.application.http.server.configuration
        let link = "https://\(configuration.hostname):\(configuration.port)/verified?\(user.verification)"
        let text = "Please verify your email address, by clicking on this link:\n\n.\(link)"
        let html = """
            <h1>Please verify your email address.</h1>
            <p>Please verify your email address, by clicking on <a href="\(link)">this link</a>.</p>"
        """
        
        let message = MailgunMessage(
            from: "postmaster@mailgun.elegantchaos.com",
            to: user.email,
            subject: "Please verify your email address",
            text: text,
            html: html
        )
        
        do {
            let response = try await req.mailgun().send(message).get()
            print(response.status.code)
        } catch {
            req.logger.warning("Error throw sending verification email to \(user.email).")
        }
    }

}
