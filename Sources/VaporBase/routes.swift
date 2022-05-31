import Fluent
import Vapor

func routes(_ app: Application) throws {
//     let sessionEnabled = app.grouped(
//         SessionsMiddleware(session: app.sessions.driver)
//     )
//
     let sessionProtected = app.grouped(
         SessionsMiddleware(session: app.sessions.driver),
         Token.sessionAuthenticator()
     )
    
    try app.register(collection: LoginController())
    try app.register(collection: SplashController())
    try sessionProtected.register(collection: UserController())
    try sessionProtected.register(collection: MainController())
    try sessionProtected.register(collection: AdminController())
    try app.register(collection: RegistrationController())
}
