// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 26/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Fluent
import Mailgun
import Vapor

extension PathComponent {
    static let logout: PathComponent = "logout"
    static let profile: PathComponent = "profile"
    static let verify: PathComponent = "verify"
    static let verified: PathComponent = "verified"
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.profile, use: requireUser(handleGetProfile))
        routes.post(.profile, use: requireUser(handlePostProfile))
        routes.get(.verify, use: requireUser(requireVerified: false, handleGetVerify))
        routes.post(.verify, use: requireUser(requireVerified: false, handlePostVerify))
        routes.get(.verified, use: requireUser(requireVerified: false, handleGetVerified))
        routes.get(.logout, use: handleGetLogout)
    }
    
    func handleGetProfile(_ req: Request, for user: User) async throws -> Response {
        return try await req.render(ProfilePage(user: user), user: user)
    }
    
    func handlePostProfile(_ req: Request, for user: User) async throws -> Response {
        let formData = try ProfilePage.Form(from: req)
        user.name = formData.name
        user.email = formData.email
        if !formData.password.isEmpty, let newHash = try? await req.password.async.hash(formData.password) {
            user.passwordHash = newHash
        }
        
        try await user.save(on: req.db)
        return req.redirect(to: .main)
    }
    
    func handleGetVerify(_ req: Request, user: User) async throws -> Response {
        guard !user.isEmailVerified else {
            return req.redirect(to: .main)
        }
        
        if user.verification.isEmpty {
            // generate a new code and send a verification email
            user.verification = generateCode(length: VaporBaseSite.codeLength)
            try await user.save(on: req.db)
            await sendVerificationMessage(req, user: user)
        }
        
        let message = "A verification code was sent to \(user.email). Please enter the code below to confirm that you own that email address."
        return try await req.render(VerifyPage(message: message))
    }

    func handleGetVerified(_ req: Request, user: User) async throws -> Response {
        let code = try req.query.decode(String.self)
        return try await handleVerification(req, user: user, rawCode: code)
    }

    func handlePostVerify(_ req: Request, user: User) async throws -> Response {
        let form = try VerifyPage.Form(from: req)
        return try await handleVerification(req, user: user, rawCode: form.code)
    }

    func handleVerification(_ req: Request, user: User, rawCode: String) async throws -> Response {
        guard !user.isEmailVerified else {
            return req.redirect(to: .main)
        }
        
        guard let code = rawCode.sanitized else {
            let message = "The code was invalid. Please re-enter it."
            return try await req.render(VerifyPage(message: message))
        }
        
        if user.verification == code {
            user.isEmailVerified = true
            try await user.save(on: req.db)
            return req.redirect(to: .main)
        }
        
        let message = "The code \(code) didn't match. Please re-enter it."
        return try await req.render(VerifyPage(message: message))
    }
    
    func handleGetLogout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        req.session.destroy()
        return req.redirect(to: .login)
    }

    func sendVerificationMessage(_ req: Request, user: User) async {
        let application = req.application
        let link = "\(application.httpAddress)/verified?\(user.verification)"
        let text = """
            Please verify your email address, by clicking on this link:\n\n.\(link)
            
            Alternatively, return to \(application.httpAddress) and enter the code \(user.verification).
        """
        
        let html = """
            <h1>Please verify your email address.</h1>
            <p>Please verify your email address, by clicking on <a href="\(link)">this link</a>.</p>
            <p>Alternatively, return to <a href="\(application.httpAddress)">\(application.httpShort)</a> and enter the code <code>\(user.verification)</code>.</p>
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

    func generateCode(length: Int) -> String {
        let components = "0123456789ABCDFGHJKLMNPQRTVWXY"
        var code = ""
        for _ in 0..<length {
            code.append(components.randomElement()!)
        }
        return code
    }
}
