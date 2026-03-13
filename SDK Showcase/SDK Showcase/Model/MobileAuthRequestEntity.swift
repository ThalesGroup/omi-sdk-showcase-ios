//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS

enum MobileAuthAuthenticatorType: String {
    case biometric = "biometric"
    case pin = "PIN"
    case custom = "custom"
    case confirmation = ""
}

class MobileAuthRequestEntity {
    var pin: String?
    var pinLength: Int?
    var pinChallenge: PinChallenge?
    var biometricChallenge: BiometricChallenge?
    var userProfile: UserProfile?
    var transactionId: String?
    var message: String?
    var authenticatorType: MobileAuthAuthenticatorType?
    var customAuthChallenge: CustomAuthFinishAuthenticationChallenge?
    var data = ""
    var cancelled = false
    var confirmation: ((Bool) -> Void)?
}
