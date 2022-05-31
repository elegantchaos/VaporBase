

struct LoginPage: LeafPage {
    let request: LoginRequest?
    
    init(request: LoginRequest? = nil) {
        self.request = request
    }
    
    func meta(for user: User?) -> PageMetadata {
        .init("Login", description: "Login")
    }
}
