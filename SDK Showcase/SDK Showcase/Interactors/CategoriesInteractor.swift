//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

//MARK: - Protocol
protocol CategoriesInteractor {
    func loadCategories() -> [Category]
    func category(of type: Categories) -> Category?
}

//MARK: - Real methods
class CategoriesInteractorReal: CategoriesInteractor {
    private var cache = [Category]()
    private var interactor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }

    func loadCategories() -> [Category] {
        guard cache.isEmpty else {
            return cache
        }
        
        let categories = [
            Category(name: Categories.initialization.rawValue,
                     description: "The SDK has to be initialized before any other operation",
                     options: [Option(name: Options.initialize.rawValue,
                                      logo: "figure.run"),
                               Option(name: Options.autoinitialize.rawValue,
                                                logo: "autostartstop"),
                               Option(name: Options.ifpLogin.rawValue)],
                     selections: [],
                     requiredActions: [Action(name: "setConfigModel",
                                              description: "Sets config model"),
                                       Action(name: "setX509PEMCertificates",
                                              description: "Sets PEM certificates",
                                              defaultValue: SDKConfigModel.defaultCert),
                                       Action(name: "setPublicKey",
                                              description: "Sets public key",
                                              defaultValue: SDKConfigModel.defaultPublicKey),
                     ],
                     optionalActions: [Action(name: "setAdditionalResourceURL",
                                              description: "Sets additional source"),
                                       Action(name: "setDeviceConfigCacheDuration",
                                              description: "Sets the device config's cache duration",
                                              defaultValue: 60.0),
                                       Action(name: "setHttpRequestTimeout",
                                              description: "Sets HTTP request timeout",
                                              defaultValue: 30.0),
                                       Action(name: "setStoreCookies",
                                              description: "Sets a flag which alows to store cookies",
                                              defaultValue: true),
                     ]),
            Category(name: Categories.userRegistation.rawValue,
                     description: "You can register your account here",
                     options: [Option(name: Options.cancel.rawValue)],
                     selections: [],
                     requiredActions: [],
                     optionalActions: [Action(name: "Stateless",
                                              description: "Register a temporary user (data will be deleted after session ends)",
                                              defaultValue: false)]),
            Category(name: Categories.userAuthentication.rawValue,
                     description: "Here you can choose a profile to authenticate and all registered authenticators for it. After authentication you can register other authenticators.",
                     options: [Option(name: Options.registerAuthenticator.rawValue, logo: "key")],
                     selections: [],
                     requiredActions: [],
                     optionalActions: [Action(name: "Implicitly",
                                              description: "The iOS SDK allows you to authenticate users implicitly (without user interaction) using the device credentials. You can use it only for regular authentication, mobile authentication is not supported. Before you start using the implicit authentication, you have to manually enable it in the client configuration in the IDAAS-core.",
                                              defaultValue: false)]),
            Category(name: Categories.mobileAuthentication.rawValue,
                     description: "Here you can enroll your device for mobile authentication and register for push notifications. ",
                     options: [Option(name: Options.enroll.rawValue, logo: "iphone"),
                               Option(name: Options.pushes.rawValue, logo: "app.badge")],
                     selections: [Selection(name: Selections.loginWithOtp.rawValue, disabled: true)],
                     requiredActions: [],
                     optionalActions: []),
            Category(name: Categories.pendingTransactions.rawValue,
                     description: "The list of transactions waiting to be confirmed.",
                     options: [],
                     selections: [],
                     requiredActions: [],
                     optionalActions: []),
            Category(name: Categories.userLogout.rawValue,
                     description: "You can logout your account here",
                     options: [],
                     selections: [],
                     requiredActions: [],
                     optionalActions: []),
            Category(name: Categories.userDeregistation.rawValue,
                     description: "You can deregister your account here",
                     options: [],
                     selections: [],
                     requiredActions: [],
                     optionalActions: []),
            Category(name: Categories.pinChange.rawValue,
                     description: "You can change your PIN here",
                     options: [Option(name: Options.changePin.rawValue,
                                      logo: "pin")],
                     selections: [],
                     requiredActions: [],
                     optionalActions: []),
            Category(name: Categories.tokens.rawValue,
                     description: "Check all the tokens you have been registered with",
                     options: [],
                     selections: [],
                     requiredActions: [],
                     optionalActions: []),
            Category(name: Categories.sso.rawValue,
                     description: "App-to-web single sign-on (SSO) allows you to take a session from your mobile application and extend it to a browser on the same device. This is useful for giving a seamless experience to your users when they transition from the mobile application to the website where more functionality likely exists. This functionality can only be used when using the IDAAS-core identity providers. This can be configured in the IDAAS-core.",
                     options: [Option(name: Options.sso.rawValue,
                                      logo: "signpost.right")],
                     selections: [],
                     requiredActions: [],
                     optionalActions: []),
            Category(name: Categories.resources.rawValue,
                     description: """
                     The iOS SDK can fetch a secure resource in three ways:\n                     
                     - For a resource that is tied to a user (such as account information or transactions), the iOS SDK can execute a secured resource access authenticated request.\n
                     - For a resource that is tied to an application but not unique per user, for example application assets, the iOS SDK can execute an anonymous request.\n
                     - For a resource that can be fetched without any additional authentication, but for which you would still like to use certificate pinning and jailbreak or debug detection, the iOS SDK can execute an unauthenticated requests.
                     """,
                     options: [],
                     selections: [Selection(name: Selections.authenticatedRequest.rawValue),
                                  Selection(name: Selections.implicitRequest.rawValue),
                                  Selection(name: Selections.unauthenticatedRequest.rawValue),
                                  Selection(name: Selections.anonymousRequest.rawValue)],
                     requiredActions: [],
                     optionalActions: []),

        ]
        self.cache = categories
        return categories
    }
    
    func category(of type: Categories) -> Category? {
        loadCategories().first(where: { $0.type == type })
    }
}
