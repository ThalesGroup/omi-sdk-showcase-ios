//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension ShowcaseApp {
    class System: Equatable, ObservableObject {
        @Published var isSDKInitialized = false
        @Published var isProcessing = false
        // POC - Start
        ///Extension Engine
        @Published var isFidoRegistration = false
        // POC - End
        @Published var store = PersistenceStore(store: UserDefaultsStore())

        @Published private(set) var lastInfoDescription: String? = nil
        @Published private(set) var userState: UserState = .notRegistered
        @Published private(set) var enrollmentState: EnrollmentState = .unenrolled
        @Published private(set) var pinPadState: PinPadState = .hidden
        @Published private(set) var scannerState: ScannerState = .hidden
        @Published private(set) var promptState: PromptState = .hidden
        // POC - Start
        ///Extension Engine
        @Published private(set) var fidoChallengeState: FidoChallengeState = .hidden
        // POC - End

        var autoinitializeSDK: Bool {
            get {
                store.autoinitializeSDK
            }
            set {
                store.autoinitializeSDK = newValue
            }
        }
        
        var hasError: Bool {
            lastInfoDescription != nil
        }
                
        var shouldShowBrowser: Bool {
            get {
                switch userState {
                case .registering(let type):
                    return type == .browser
                case .sso:
                    return true
                default:
                    return false
                }
            }
            set {
                if newValue {
                    userState = .registering(.browser)
                }
            }
        }
        
        func setScannerState(_ newState: ScannerState) {
            scannerState = newState
        }
        
        func setUserState(_ newState: UserState) {
            userState = newState
        }
        
        func setPromptState(_ newState: PromptState) {
            promptState = newState
        }

        // POC - Start
        ///Extension Engine
        func setFidoChallengeState(_ newState: FidoChallengeState) {
            fidoChallengeState = newState
        }
        // POC - End
        
        func setEnrollmentState(_ newState: EnrollmentState) {
            enrollmentState = newState
        }
        
        func setPinPadState(_ newState: PinPadState) {
            pinPadState = newState
        }
   
        var shouldShowPinPad: Bool {
            get { pinPadState != .hidden }
            set { pinPadState = newValue ? .changing : .hidden }
        }
        
        var shouldShowScanner: Bool {
            get { scannerState != .hidden }
            set { scannerState = newValue ? .showForOTP : .hidden }
        }
        
        var shouldShowPrompt: Bool {
            get { promptState != .hidden }
            set { promptState = newValue ? .shown : .hidden }
        }

        // POC - Start
        ///Extension Engine
        var shouldShowFidoChallenge: Bool {
            get { fidoChallengeState != .hidden }
            set { fidoChallengeState = newValue ? .shown(serverPrompt: "") : .hidden }
        }

        var fidoServerPrompt: String {
            if case .shown(let prompt) = fidoChallengeState {
                return prompt
            }
            return ""
        }
        // POC - End
        
        func setInfo(_ description: String) {
            lastInfoDescription = description
        }
        
        func unsetInfo() {
            lastInfoDescription = nil
        }

        func reset() {
            isSDKInitialized = false

            enrollmentState = .unenrolled
            userState = .notRegistered
            pinPadState = .hidden
            
            unsetInfo()
        }
    }
}

extension ShowcaseApp.System {
    static func == (lhs: ShowcaseApp.System, rhs: ShowcaseApp.System) -> Bool {
        lhs.isSDKInitialized == rhs.isSDKInitialized &&
        lhs.enrollmentState == rhs.enrollmentState
    }
}
