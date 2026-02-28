//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

//MARK: - Actions for Options
extension ContentView {
    func setBuilder() {
        sdkInteractor.setConfigModel(SDKConfigModel.default)
        sdkInteractor.setPublicKey(value(for: "setPublicKey"))
        sdkInteractor.setCertificates([value(for: "setX509PEMCertificates")])
        sdkInteractor.setAdditionalResourceUrls([value(for: "setAdditionalResourceURL")])
        sdkInteractor.setStoreCookies(value(for: "setStoreCookies"))
        sdkInteractor.setHttpRequestTimeout(value(for: "setHttpRequestTimeout"))
        sdkInteractor.setDeviceConfigCacheDuration(value(for: "setDeviceConfigCacheDuration"))
    }
    
    func initializeSDK(automatically: Bool) {
        guard category.type == .initialization else { return }

        app.system.autoinitializeSDK = automatically
        errorValue.removeAll()
        /// You can uncomment the below line if the app is not configured with the configurator and does not have OneginiConfigModel set.
        //setBuilder()
        sdkInteractor.initializeSDK { result in
            switch result {
            case .success:
                system.unsetInfo()
                system.isSDKInitialized = true
                registrationInteractor.fetchUserProfiles()
                mobileAuthRequestInteractor.fetchEnrollment()
            case .failure(let error):
                errorValue = error.localizedDescription
                system.setInfo(errorValue)
                system.isSDKInitialized = false
            }
            system.isProcessing = false
        }
    }
    
    func ifpLogin() {
        sdkInteractor.ifpLogin()
    }
    
    func resetSDK() {
        errorValue.removeAll()
        setBuilder()
        sdkInteractor.resetSDK { result in
            switch result {
            case .success:
                system.unsetInfo()
                system.isSDKInitialized = false
                app.setSystemInfo(string: "The SDK has been reset successfully.")
            case .failure(let error):
                errorValue = error.localizedDescription
                system.setInfo(errorValue)
                app.setSystemInfo(string: "There was an error resetting the SDK: \(errorValue)")
            }
        }
    }
    
    func changePIN() {
        pinPadInteractor.changePin()
    }
    
    func sso() {
        authenticatorInteractor.sso()
    }
    
    func sendAuthenticatedRequest() {
        resourceInteractor.sendAuthenticatedRequest()
    }
    
    func sendUnauthenticatedRequest() {
        resourceInteractor.sendUnauthenticatedRequest()
    }
    
    func sendAnonymousRequest() {
        resourceInteractor.sendAnonymousRequest()
    }
    
    func sendImplicitRequest() {
        resourceInteractor.sendImplicitRequest()
    }
    
    func enrollForMobileAuthentication() {
        mobileAuthRequestInteractor.enrollForMobileAuthentication()
    }
    
    func registerForPushes() {
        pushNotitificationsInteractor.registerForPushNotifications()
    }
    
    func registerAuthenticator() {
        if case .authenticated = system.userState {
            selectedOption = nil
            showConfirmationDialog = true
        } else {
            app.setSystemInfo(string: "You must be authenticated to perform this action.")
        }
        system.isProcessing = false
    }
    
    func updateMobileAuthenticationCategorySelection() {
        guard category.type == .mobileAuthentication, app.system.enrollmentState != EnrollmentState.unenrolled else { return }
        category.selections = [Selection(name: Selections.loginWithOtp.rawValue)]
    }
    
    func updateIdentityProviders() {
        guard category.type == .userRegistation else { return }
        category.selections = authenticatorInteractor.fetchIdentityProviders().map { Selection(name: $0.name, type: .register) }
    }
    
    func updateUsersSelection() {
        guard category.type == .userAuthentication else { return }
        category.selections = registrationInteractor.userAuthenticatorOptionNames.map { Selection(name: $0, type: .authenticate, logo: "person.crop.circle") }
    }
    
    func updateLogout() {
        guard category.type == .userLogout else { return }
        let userId = app.system.userState.userId
        category.selections = registrationInteractor.userAuthenticatorOptionNames.filter { $0 == userId }.map { Selection(name: $0, type: .logout, logo: "person.crop.circle") }
    }
    
    func updateDeregister() {
        guard category.type == .userDeregistation else { return }
        category.selections = registrationInteractor.userAuthenticatorOptionNames.map { Selection(name: $0, type: .deregister, logo: "person.crop.circle") }
    }
    
    func pendingTransactionsTask() {
        guard category.type == .pendingTransactions else { return }
        Task {
            let pendingTransactions = await mobileAuthRequestInteractor.fetchPendingTransactionNames()
            category.selections = pendingTransactions.map { Selection(name: $0, type: .pending, logo: "doc.badge.clock") }
        }
    }
    
    func updateTokens() {
        guard category.type == .tokens  else { return }
        if let _ = authenticatorInteractor.accessToken {
            category.selections.append(Selection(name: Token.access.rawValue, type: .token))
        }
        if let _ = authenticatorInteractor.openIDtoken {
            category.selections.append(Selection(name: Token.openID.rawValue, type: .token))
        }
    }
}

//MARK: - Actions for Selections
extension ContentView {
    
    func startRegistration(authenticatorName: String) {
        registrationInteractor.setStateless(value(for: "Stateless"))
        registrationInteractor.register(with: authenticatorName)
    }

    func cancelRegistration() {
        registrationInteractor.cancelRegistration()
        system.isProcessing = false
    }
}
    
//MARK: - Helpers
extension ContentView {
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    var mobileAuthRequestInteractor: MobileAuthRequestInteractor {
        @Injected var interactors: Interactors
        return interactors.mobileAuthRequestInteractor
    }
    
    var authenticatorInteractor: AuthenticatorInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorInteractor
    }
    
    var resourceInteractor: ResourceInteractor {
        @Injected var interactors: Interactors
        return interactors.resourceInteractor
    }
    
    var authenticatorRegistrationInteractor: AuthenticatorRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorRegistrationInteractor
    }
    
    var registrationInteractor: RegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.registrationInteractor
    }
    
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }

    var pushNotitificationsInteractor: PushNotitificationsInteractor {
        @Injected var interactors: Interactors
        return interactors.pushInteractor
    }
    
    var initializationStatus: String {
        system.isSDKInitialized ? "✅ SDK initialized" : "❌ SDK not initialized \(errorValue)"
    }
    
    var userStateDescription: String {
        switch system.userState {
        case .notRegistered:
            "🚫 No user registered"
        case .registering:
            "⏳ Registration in progress..."
        case .sso:
            "🔑 SSO in progress..."
        case .registered, .unauthenticated:
            "👥 \(registrationInteractor.numberOfRegisteredUsers) registered users"
        case .authenticated(let userId):
            "👤 User authenticated as \(userId)"
        case .stateless:
            "🤖 Stateless user authenticated"
        case .implicit:
            "👻 Implicitly authenticated"
        }
    }
    
    var enrollmentStateDescription: String {
        switch system.enrollmentState {
        case .unenrolled:
            "⚠️ User not enrolled for mobile authentication"
        case .mobile:
            "📲 User enrolled for mobile authentication"
        case .push:
            "📳 User enrolled for push notifications"
        }
    }
    
    func binding(for action: Action) -> Binding<Action> {
        setDefaultValueIfNeeded(for: action)
        return .init(
            get: {
                return actions.first { $0 == action } ?? action
            },
            set: { newAction in
                actions.removeAll { $0 == action }
                actions.append(newAction)
            }
        )
    }
    
    func setDefaultValueIfNeeded(for action: Action) {
        DispatchQueue.main.async {
            if !actions.contains(action) {
                actions.append(action)
            }
        }
    }
    
    func value<T>(for key: String) -> T {
        guard let action = actions.first(where: { $0.name == key }),
            let value = action.providedValue ?? action.defaultValue else {
            return [] as? T
            ?? String() as? T
            ?? Int() as? T
            ?? Double() as? T
            ?? Bool() as! T
        }
        
        guard let cast = value as? T else {
            switch T.self {
            case is Int.Type:
                return Int(value as! String) as! T
            case is Double.Type:
                return Double(value as! String) as! T
            default:
                fatalError("Unsupported type \(type(of: value))")
            }
        }

        return cast
    }
}
