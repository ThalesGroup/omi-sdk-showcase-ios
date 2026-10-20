//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

// POC - Start
// NOTE: This file requires the TGFido2 framework to be linked to the project.
// Add it via Swift Package Manager or as an XCFramework before building.
// The TGFido2 framework is part of the OneWelcome Mobile FIDO SDK.
import Foundation
import Fido2

// MARK: - FidoUiDelegate

/// FIDO2 UI delegate for authenticator selection during registration or authentication.
/// Implements TGFido2UiDelegate as described in the Mobile FIDO SDK documentation
/// (Registering an authenticator – Authenticator selection section).
///
/// When multiple authenticators are available, the FIDO2 SDK calls
/// `showAuthenticatorSelection(_:authenticatorSelectedHandler:cancelHandler:)` to let
/// the app present a picker to the user.
class FidoUiDelegate: NSObject, TGFFido2UiDelegate, TGFPasscodeAuthenticatorDelegate, TGFBiometricAuthenticatorDelegate {
    
    /// TGFBiometricAuthenticatorDelegate
    func biometricAuthenticatorTouchIdMessagePrompt(_ operationInfo: TGFFido2OperationInfo) -> String {
        return "Touch ID is required."
    }

    func biometricAuthenticatorShouldStart(_ operationInfo: TGFFido2OperationInfo, biometryType: LABiometryType, startHandler: @escaping (Bool) -> Void) {
        startHandler(true)
    }

    
    /// Called by the TGFFido2Client when multiple authenticators are available and
    /// the user must select one to proceed with registration or authentication.
    ///
    /// - Parameters:
    ///   - authenticators: The list of available FIDO2 authenticators (TGFido2AuthenticatorInfo).
    ///   - authenticatorSelectedHandler: Call this closure with the selected authenticator
    ///     info to proceed with registration/authentication.
    ///   - cancelHandler: Call this closure if the user cancels the selection.
    func showAuthenticators(_ authenticators: [TGFFido2AuthenticatorInfo], operationInfo: TGFFido2OperationInfo, authenticatorSelectionHandler: @escaping (TGFFido2AuthenticatorInfo) -> Void, cancelHandler: @escaping () -> Void) {
        // Display list of authenticators to the user and let them choose.
        // For now, automatically select the first available authenticator.
        // In a production app, this would present a SwiftUI/UIKit picker to the user.
        guard let firstAuthenticator = authenticators.first else {
            cancelHandler()
            return
        }

        // Callback with the selected authenticator
        authenticatorSelectionHandler(firstAuthenticator)

        // OR cancel:
        // cancelHandler()
    }

    func retrieveAuthenticatorDescription(_ selectedAuthenticator: TGFFido2AuthenticatorInfo, authenticatorDescriptionHandler: @escaping (TGFAuthenticatorDescriptor) -> Void, cancelHandler: @escaping () -> Void) {
    }

    func showTransactionDetails(_ transactionDetails: [String : String], proceedHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) {
    }
}
// POC - End
