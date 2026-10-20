//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol RegistrationInteractor {
    var registerUrl: String { get set }
    var userAuthenticatorOptionNames: [String] { get }
    var numberOfRegisteredUsers: Int { get }

    func fetchUserProfiles()
    func setUserPrompt(_ prompt: String)
// POC - Start
    func setFidoUserPrompt(_ prompt: String)
// POC - End
    func setBrowserChallenge(_ challenge: BrowserRegistrationChallenge)
    func setCustomChallenge(_ challenge: CustomRegistrationChallenge)
    func setStateless(_ stateless: Bool)
    func register(with provider: String, stateless: Bool)
    func register(with idp: String)
    func deregister(optionName: String)
    func cancelRegistration()
    func didReceiveBrowserRegistrationRedirect(_ url: URL)
}

//MARK: - Real methods
class RegistrationInteractorReal: RegistrationInteractor {
    @ObservedObject var app: ShowcaseApp
    private let userClient = SharedUserClient.instance
    private var browserChallenge: BrowserRegistrationChallenge?
    private var customChallenge: CustomRegistrationChallenge?
    private var stateless = false
    var registerUrl: String

    init(registerUrl: String = "", app: ShowcaseApp) {
        self.registerUrl = registerUrl
        self.app = app
    }
    
    var userAuthenticatorOptionNames: [String] {
        return app.registeredUsers.map { $0.userId }
    }
    
    var numberOfRegisteredUsers: Int {
        return app.registeredUsers.filter { $0.isStateless == false }.map { $0.userId }.count
    }

    func setBrowserChallenge(_ challenge: any BrowserRegistrationChallenge) {
        self.registerUrl = challenge.url.absoluteString
        self.browserChallenge = challenge
    }
    
    func setCustomChallenge(_ challenge: any CustomRegistrationChallenge) {
        self.customChallenge = challenge
    }
    
    func setStateless(_ stateless: Bool) {
        self.stateless = stateless
    }
    
    func register(with idp: String) {
        guard app.system.isSDKInitialized else {
            app.setSystemInfo(string: "SDK not initialized")
            return
        }
        register(with: idp, stateless: stateless)
    }
    
    func deregister(optionName: String) {
        guard let userProfile = userClient.userProfiles.first(where: { user in user.profileId == optionName }) else {
            if optionName == UserState.stateless.rawValue {
                app.setSystemInfo(string: "Deregistration cannot be performed for the stateless user.")
            } else {
                app.setSystemInfo(string: "Deregistration failed. The profile has been already unregistered.")
            }
            return
        }
        userClient.deregister(user: userProfile) { [self] error in
            if error != nil {
                app.setSystemInfo(string: "Deregistration failed. The profile has not been found.")
            } else {
                app.remove(profileId: userProfile.profileId)
                app.setSystemInfo(string: "Profile \(optionName) has been deregister.")
            }
        }
    }
    
    func fetchUserProfiles() {
        app.resetRegisteredUsers()
        userClient.userProfiles
            .map { ShowcaseApp.UserData(userId: $0.profileId, authenticatorsNames: authenticatorRegistrationInteractor.authenticatorNames(for: $0.profileId)) }
            .forEach { app.addRegisteredUser($0) }
    }
    
    func register(with provider: String, stateless: Bool) {
        app.system.isProcessing = true
        let scopes = ["read", "openid", "email", "profile", "write"]
        let provider = userClient.identityProviders.first(where: { $0.name == provider })

        if stateless {
            userClient.registerStatelessUserWith(identityProvider: provider, scopes: scopes, delegate: self)
        } else {
            userClient.registerUserWith(identityProvider: provider, scopes: scopes, delegate: self)
        }
    }
    
    func cancelRegistration() {
        if let browserChallenge {
            browserChallenge.sender.cancel(browserChallenge)
        } else if let customChallenge {
            customChallenge.sender.cancel(customChallenge, withUnderlyingError: nil)
        }
        app.system.setPromptState(.hidden)
        app.system.setFidoChallengeState(.hidden)
        app.system.setScannerState(.hidden)
        browserChallenge = nil
        customChallenge = nil
        switch app.system.userState {
        case .sso:
            if let userId = userClient.authenticatedUserProfile?.profileId {
                app.system.setUserState(.authenticated(userId))
            } else {
                app.system.setUserState(.registered)
            }
        default:
            let stateless = userClient.isStateless && userClient.accessToken != nil
            app.system.setUserState(stateless ? .stateless : .unauthenticated)
        }
        app.system.isProcessing = false
    }
    
    func didRegisterUser(profileId: String) {
        let userData = ShowcaseApp.UserData(userId: profileId,
                                         isStateless: stateless,
                                         authenticatorsNames: authenticatorRegistrationInteractor.authenticatorNames(for: profileId))
        app.addRegisteredUser(userData, authenticate: true)
        app.system.setEnrollmentState(.unenrolled)
        app.system.setPinPadState(.hidden)
        app.system.setScannerState(.hidden)
        app.system.setPromptState(.hidden)
        app.system.setFidoChallengeState(.hidden)
        pinPadInteractor.resetChallenges()
        browserChallenge = nil
        customChallenge = nil
        app.setSystemInfo(string: "Profile \(profileId) has been registered successfully.")
    }
}

//MARK: - SDK Delegates
extension RegistrationInteractorReal {

    func didReceiveBrowserRegistrationRedirect(_ url: URL) {
        guard let browserChallenge else { return }
        browserChallenge.sender.respond(with: url, to: browserChallenge)
    }
    
    func didReceiveBrowserRegistrationChallenge(_ challenge: any OneginiSDKiOS.BrowserRegistrationChallenge) {
        setBrowserChallenge(challenge)
        app.system.setUserState(.registering(.browser))
    }
    
    func didReceiveCustomRegistrationFinishChallenge(_ challenge: any OneginiSDKiOS.CustomRegistrationChallenge) {
        setCustomChallenge(challenge)
        app.system.setUserState(.registering(.api))
        
        // POC - START
        // DigiD works regardless stateless
        if isPocDigidTwoStep(challenge) {
            guard let urlString = challenge.info?.data, let url = URL(string: urlString) else {
                // random error passed just to cancel
                challenge.sender.cancel(challenge, withUnderlyingError: SDKError.unknown)
                return
            }
            // TODO: what if the DigiD app refuse to handle that error? Do some kind of timout
            UIApplication.shared.open(url)
            return
        }
        // POC - END
        
        if stateless {
            challenge.sender.respond(with: nil, to: challenge)
        } else {
            if isTypeOfTwoStepRegistration(challenge) {
                /// Prompt for the input
                
                // POC - Start
                ///Extension Engine
                /// Persist the challenge data for the poc_fido_reg_2_step identity provider
                if challenge.identityProvider.identifier == "poc_fido_reg_2_step" {
                    let serverPromptValue = challenge.info?.data ?? ""
                    app.system.store.fidoRegData = serverPromptValue
                    app.system.setFidoChallengeState(.shown(serverPrompt: serverPromptValue))
                } else if challenge.identityProvider.identifier == "poc_fido_auth_2_step" {
                    let serverPromptValue = challenge.info?.data ?? ""
                    app.system.setFidoChallengeState(.shown(serverPrompt: serverPromptValue))
                } else {
                // POC - End
                    app.system.setPromptState(.shown)
                }
            } else {
                /// You can ask the user about the response for one step registration in different ways, e.g. by asking for password or scanning the QR code:
                qrScannerInteractor.scan(to: self)
            }
        }
    }
    
    // POC - Start
    ///Extension Engine
    func convertServerPromptToDictionary(_ jsonString: String) -> [String: Any]? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
    }
    // POC - End

    func didReceiveCustomRegistrationInitChallenge(_ challenge: any OneginiSDKiOS.CustomRegistrationChallenge) {
        setCustomChallenge(challenge)
        app.system.setUserState(.registering(.api))
        if stateless {
            challenge.sender.respond(with: nil, to: challenge)
        } else {
            // POC - Start
            ///Extension Engine
            if challenge.identityProvider.identifier == "poc_fido_auth_2_step" {
                app.system.isFidoRegistration = false
                guard
                    let data = app.system.store.fidoRegData.data(using: .utf8),
                    let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                else {
                    app.setSystemInfo(string: "No saved FIDO2 registration data found for authentication.")
                    challenge.sender.cancel(challenge, withUnderlyingError: SDKError.unknown)
                    return
                }
                let userId = dict["userId"]
                let fidoData = ["userId": userId ?? ["userId": ""]] as [String: Any]
                do {
                    let jsonData = try JSONSerialization.data(
                        withJSONObject: fidoData,
                        options: [.prettyPrinted] // optional
                    )
                    
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        challenge.sender.respond(with: jsonString, to: challenge)
                    }
                } catch {
                    print("Failed to convert dictionary to JSON: \(error)")
                    challenge.sender.cancel(challenge, withUnderlyingError: error)
                }
                
            } else if challenge.identityProvider.identifier == "poc_fido_reg_2_step" {
                app.system.isFidoRegistration = true
                challenge.sender.respond(with: "", to: challenge)
            } else {
                challenge.sender.respond(with: DummyData.customAuthInitialChallenge, to: challenge)
            }
            // POC - End
            
        }
    }
    
    func didFailToRegisterUser(with error: Error) {
        switch SDKError(error) {
        case .statelessDisabled:
            app.setSystemInfo(string: "Stateless registration is not supported or not configured by the server.")
        case .registrationCancelled:
            app.setSystemInfo(string: "Registration has been canceled.")
        default:
            app.setSystemInfo(string: error.localizedDescription)
        }
        app.system.setPromptState(.hidden)
        app.system.setFidoChallengeState(.hidden)
        app.system.setScannerState(.hidden)
        browserChallenge = nil
        customChallenge = nil
    }
}

extension RegistrationInteractorReal: QRScannerDelegate {
    func didStartScanning() {
        app.system.setScannerState(.showForRegistration)
    }

    func didCancelScanning() {
        app.system.setScannerState(.hidden)
    }

    func didFinishScanning(code: String) {
        guard let customChallenge else { return }
        customChallenge.sender.respond(with: code, to: customChallenge)
        app.system.setScannerState(.hidden)
    }
    
    func setUserPrompt(_ prompt: String) {
        guard let customChallenge else { return }
        app.system.setPromptState(.hidden)
        customChallenge.sender.respond(with: prompt, to: customChallenge)
    }
    
    // POC - Start
    ///Extension Engine
    func setFidoUserPrompt(_ jsonResponse: String) {
        guard let customChallenge else { return }

        guard
            let data = app.system.store.fidoRegData.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return
        }
        let stringToFinishReq: [String: String] = [
                    "fido2": jsonResponse,
                    "userId": dict["userId"] as! String
                ]
   
        guard let jsonData = try? JSONSerialization.data(withJSONObject: stringToFinishReq, options: []),
        
        let jsonString = String(data: jsonData, encoding: .utf8) else {
            fatalError("Killer")
        }
        customChallenge.sender.respond(with: jsonString, to: customChallenge)
    }
    // POC - End
}

private extension RegistrationInteractorReal {
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    var authenticatorRegistrationInteractor: AuthenticatorRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorRegistrationInteractor
    }
    
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }

    // POC - Start
    ///Extension Engine
    var fidoRegistrationInteractor: Fido2Interactor {
        @Injected var interactors: Interactors
        return interactors.fidoRegistrationInteractor
    }
    // POC - End

    var device: ShowcaseApp.DeviceData { app.deviceData }
    
    func isTypeOfTwoStepRegistration(_ challenge: any OneginiSDKiOS.CustomRegistrationChallenge) -> Bool {
        // POC - Start
        ///Extension Engine
        let twoStepIdentifier = ["New2step", "poc_fido_reg_2_step", "poc_fido_auth_2_step"]
        // POC - End
        return twoStepIdentifier.contains(challenge.identityProvider.identifier)
    }
    // POC - START
    func isPocDigidTwoStep(_ challenge: any OneginiSDKiOS.CustomRegistrationChallenge) -> Bool {
        return ["poc_digid_two_step"].contains(challenge.identityProvider.identifier)
    }
    // POC - END
}

extension RegistrationInteractorReal: RegistrationDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceiveCreatePinChallenge challenge: any OneginiSDKiOS.CreatePinChallenge) {
        app.system.isProcessing = false
        if let error = challenge.error {
            pinPadInteractor.setCreatePinChallenge(challenge)
            pinPadInteractor.showError(error)
            return
        }

        app.system.setUserState(.unauthenticated)
        pinPadInteractor.setCreatePinChallenge(challenge)
        pinPadInteractor.showPinPad(for: .creating)
    }

    func userClient(_ userClient: any UserClient, didRegisterUser profile: any UserProfile, with identityProvider: any IdentityProvider, info: (any CustomInfo)?) {
        app.system.isProcessing = false
        didRegisterUser(profileId: profile.profileId)
    }
    
    func userClient(_ userClient: any UserClient, didReceiveBrowserRegistrationChallenge challenge: any BrowserRegistrationChallenge) {
        app.system.isProcessing = false
        didReceiveBrowserRegistrationChallenge(challenge)
    }
    
    func userClient(_ userClient: any UserClient, didFailToRegisterUserWith identityProvider: any IdentityProvider, error: any Error) {
        app.system.isProcessing = false
        didFailToRegisterUser(with: error)
    }

    func userClient(_ userClient: any UserClient, didReceiveCustomRegistrationFinishChallenge challenge: any CustomRegistrationChallenge) {
        app.system.isProcessing = false
        didReceiveCustomRegistrationFinishChallenge(challenge)
    }

    func userClient(_ userClient: any UserClient, didReceiveCustomRegistrationInitChallenge challenge: any CustomRegistrationChallenge) {
        app.system.isProcessing = false
        didReceiveCustomRegistrationInitChallenge(challenge)
    }
}
