//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import Swinject

final class Injection {
    static let shared = Injection()
    private var internalContainer: Container?
    var container: Container {
        get { internalContainer ?? buildContainer() }
    }
}

//MARK: - Private extension
private extension Injection {
    func buildContainer() -> Container {
        let container = Container()
        internalContainer = container
        
        container.register(ShowcaseApp.self) { _ in ShowcaseApp() }
            .inObjectScope(.container)

        container.register(CategoriesInteractor.self)  { _ in CategoriesInteractorReal() }
            .inObjectScope(.container)
        
        container.register(PushNotitificationsInteractor.self)  { _ in PushNotitificationsInteractorReal() }
            .inObjectScope(.container)
        
        container.register(MobileAuthRequestQueue.self) { _ in MobileAuthRequestQueue() }
            .inObjectScope(.container)
        
        container.register(MobileAuthRequestEntity.self) { _ in MobileAuthRequestEntity() }
            .inObjectScope(.container)
        
        container.register(SDKInteractor.self) { resolver in
            SDKInteractorReal(app: resolver.resolve(ShowcaseApp.self)!)}
            .inObjectScope(.container)
        
        container.register(MobileAuthRequestInteractor.self) { resolver in
            MobileAuthRequestInteractorReal(app: resolver.resolve(ShowcaseApp.self)!)}
            .inObjectScope(.container)
        
        container.register(AuthenticatorInteractor.self) { resolver in
            AuthenticatorInteractorReal(app: resolver.resolve(ShowcaseApp.self)!)}
            .inObjectScope(.container)

        container.register(AuthenticatorRegistrationInteractor.self) { resolver in
            AuthenticatorRegistrationInteractorReal(app: resolver.resolve(ShowcaseApp.self)!)}
            .inObjectScope(.container)

        container.register(RegistrationInteractor.self)  { resolver in
            RegistrationInteractorReal(app: resolver.resolve(ShowcaseApp.self)!)}
            .inObjectScope(.container)
        
        container.register(PinPadInteractor.self)  { resolver in
            PinPadInteractorReal() }
            .inObjectScope(.container)
        
        container.register(QRScannerInteractor.self)  { resolver in
            QRScannerInteractorReal() }
            .inObjectScope(.container)
        
        container.register(ResourceInteractor.self) { resolver in
            ResourceInteractorReal(app: resolver.resolve(ShowcaseApp.self)!)}
            .inObjectScope(.container)

        // POC - Start
        ///Extension Engine
        container.register(Fido2Interactor.self) { resolver in
            Fido2InteractorReal(app: resolver.resolve(ShowcaseApp.self)!) }
            .inObjectScope(.container)
        // POC - End

        container.register(Interactors.self) { resolver in
            Interactors(categoriesInteractor: resolver.resolve(CategoriesInteractor.self)!,
                        sdkInteractor: resolver.resolve(SDKInteractor.self)!,
                        authenticatorInteractor: resolver.resolve(AuthenticatorInteractor.self)!,
                        authenticatorRegistrationInteractor: resolver.resolve(AuthenticatorRegistrationInteractor.self)!,
                        mobileAuthRequestInteractor: resolver.resolve(MobileAuthRequestInteractor.self)!,
                        registrationInteractor: resolver.resolve(RegistrationInteractor.self)!,
                        pinPadInteractor: resolver.resolve(PinPadInteractor.self)!,
                        qrScannerInteractor: resolver.resolve(QRScannerInteractor.self)!,
                        pushInteractor: resolver.resolve(PushNotitificationsInteractor.self)!,
                        resourceInteractor: resolver.resolve(ResourceInteractor.self)!,
                        // POC - Start
                        ///Extension Engine
                        fidoRegistrationInteractor: resolver.resolve(Fido2Interactor.self)!
                        // POC - End
            )}
            .inObjectScope(.container)
        
        return container
    }
}

//MARK: - Property wrapper
@propertyWrapper
struct Injected<Dependency> {
    var wrappedValue: Dependency
    
    init() {
        wrappedValue = Injection.shared.container.resolve(Dependency.self)!
    }
}
