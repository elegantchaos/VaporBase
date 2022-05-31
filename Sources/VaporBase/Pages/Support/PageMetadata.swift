// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

struct PageMetadata: Codable {
    var title: String
    var description: String
    let background: String
    let padding: Int
    var error: String?
    
    init(_ title: String, description: String = "", error: String? = nil) {
        self.background = "ff0000"
        self.padding = 10
        self.title = title
        self.description = description
        self.error = error
    }
}


