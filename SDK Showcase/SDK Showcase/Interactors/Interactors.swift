//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

struct Interactors {
    let categoriesInteractor: CategoriesInteractor
    let sdkInteractor: SDKInteractor
    let authenticatorInteractor: AuthenticatorInteractor
    let authenticatorRegistrationInteractor: AuthenticatorRegistrationInteractor
    let mobileAuthRequestInteractor: MobileAuthRequestInteractor
    let registrationInteractor: RegistrationInteractor
    let pinPadInteractor: PinPadInteractor
    let qrScannerInteractor: QRScannerInteractor
    let pushInteractor: PushNotitificationsInteractor
    let resourceInteractor: ResourceInteractor
    // POC - Start
    ///Extension Engine
    let fidoRegistrationInteractor: Fido2Interactor
    // POC - End
}
