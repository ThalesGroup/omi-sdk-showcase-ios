//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

enum Selections: String {
    case unknown
    case loginWithOtp = "Login with QR Code"
    case pending
    case logout
    case deregister
    case authenticate
    case register
    case token
    case authenticatedRequest = "👤 Authenticated request"
    case unauthenticatedRequest = "🖥️ Unauthencated request"
    case implicitRequest = "👤 Implicit request"
    case anonymousRequest = "🖥️ Anonymous request"
    case multipartRequest = "📎 Multipart upload (User Auth)"
}

struct Selection: AppModel {
    private(set) var type: Selections = .unknown
    let name: String
    var disabled = false
    var namedType: Selections {
        get {
            return Selections(rawValue: name) ?? .unknown
        }
        set {
            type = newValue
        }
    }
    private(set) var logo: String?
    
    init(name: String, type: Selections = .unknown, disabled: Bool = false, logo: String? = nil) {
        self.type = type
        self.name = name
        self.disabled = disabled
        self.logo = logo
    }
}
