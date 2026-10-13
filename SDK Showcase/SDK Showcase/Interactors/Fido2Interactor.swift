//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

// POC - Start
// NOTE: This file requires the TGFido2 framework to be linked to the project.
// Add it via Swift Package Manager or as an XCFramework before building.
// The TGFido2 framework is part of the OneWelcome Mobile FIDO SDK.
import Foundation
import Fido2
import SwiftUI

// MARK: - Protocol

/// Interactor responsible for handling the FIDO2 registration flow.
/// Follows the Mobile FIDO SDK registration documentation:
/// https://docs.onewelcome.com/mobileSDK/fido2-sdk/fido2-sdk-features/fido2-sdk-registration/
protocol Fido2Interactor {
    
    func setUserPrompt(_ prompt: String)
    
    /// Performs the FIDO2 registration using the provided CredentialCreationOptions JSON string.
    /// Returns the FIDO2 attestation response string to be forwarded to the server.
    ///
    /// - Parameters:
    ///   - jsonString: The CredentialCreationOptions JSON received from the server
    ///                 (i.e. the extracted FIDO2 value from `challenge.info?.data`).
    ///   - completion: Called with the FIDO2 attestation response string on success,
    ///                 or an error on failure.
    func register(with jsonString: String, completion: @escaping (Result<String, Error>) -> Void)
}

// MARK: - Real Implementation

class Fido2InteractorReal: Fido2Interactor {
    
    @ObservedObject var app: ShowcaseApp
    var fido2Client: TGFFido2Client?
    
    /// The FIDO2 UI delegate used for authenticator selection.
    private let uiDelegate: TGFFido2UiDelegate
    
    /// The FIDO2 Biometric delegate used for authenticator selection.
    private let biometricDelegate: TGFBiometricAuthenticatorDelegate
    
    /// The FIDO2 Passcode delegate used for authenticator selection.
    private let passcodeDelegate: TGFPasscodeAuthenticatorDelegate

    init(uiDelegate: TGFFido2UiDelegate = FidoUiDelegate(),
         bioDelegate: TGFBiometricAuthenticatorDelegate = FidoUiDelegate(),
         passDelegate: TGFPasscodeAuthenticatorDelegate = FidoUiDelegate(),
         app: ShowcaseApp
    ) {
        self.uiDelegate = uiDelegate
        self.biometricDelegate = bioDelegate
        self.passcodeDelegate = passDelegate
        self.app = app
    }

    func setUserPrompt(_ prompt: String) {
        if !prompt.isEmpty {
            
            guard
                let data = app.system.store.fidoRegData.data(using: .utf8),
                let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                return
            }
            let userData = ShowcaseApp.UserData(userId: dict["userId"] as! String,authenticatorsNames:[""])
            
            if app.system.isFidoRegistration {
                app.setSystemInfo(string: "FIDO2 user is registration successful.")
                app.system.setUserState(.registered)
                app.addRegisteredUser(userData, authenticate: false)
            } else {
                app.setSystemInfo(string: "FIDO2 user is authenticated successful.")
                app.system.setUserState(.authenticated(dict["userId"] as! String))
                app.addRegisteredUser(userData, authenticate: true)
            }
        } else if prompt == "fail" {
            app.setSystemInfo(string: "FIDO2 registration failed.")
            app.system.setUserState(.notRegistered)
        }
        
        app.system.isProcessing = false
    }
    
    /// Initiates a FIDO2 registration.
    ///
    /// Flow (as per the Mobile FIDO SDK documentation – Registering an authenticator):
    /// 1. Create a TGFido2RegistrationRequest from the server's CredentialCreationOptions JSON.
    /// 2. Set up a TGFido2Client with the UI delegate for authenticator selection.
    /// 3. Build TGFido2RespondArgs via TGFido2RespondArgsBuilder with UI customisation strings.
    /// 4. Call fido2Client.respond(with:respondArgs:completion:) to get the attestation response.
    /// 5. Return the response string via Result<String, Error> for the caller to forward to the server.
    func register(with jsonString: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Step 1 – Create the FIDO2 registration request from the server's JSON payload.
        // The jsonString MUST conform to CredentialCreationOptions (WebAuthn spec).
        let fidoRequest: TGFFido2Request
        
        do {
            fidoRequest = try TGFFido2RequestFactory.request(jsonString)
            // Step 2 – Set up an instance of TGFido2Client with the UI delegate.
            fido2Client = try TGFFido2ClientFactory.client()
        } catch {
            completion(.failure(error))
            return
        }
       
        // Setup an instance of TGFFido2RespondArgsBuilder,initialize all necessary UI delegates required by Mobile FIDO SDK.
        let respondArgsBuilder = TGFFido2RespondArgsBuilder(request: fidoRequest, uiDelegate: self.uiDelegate)
        respondArgsBuilder.uiBiometricAuthenticatorDelegate = self.biometricDelegate
        respondArgsBuilder.uiPasscodeAuthenticatorDelegate = self.passcodeDelegate
        respondArgsBuilder.passcodeAuthenticator = TGFPasscodeAuthenticator(delegate: self.passcodeDelegate)
        let respondArgs = respondArgsBuilder.respondArgs()

        // Step 4 – Call respond on the FIDO2 client to perform the attestation.
        // The SDK will invoke the platform authenticator (Face ID / Touch ID / passcode)
        // and return a WebAuthn attestation response JSON string.
        fido2Client?.respond(with: respondArgs) { response, error in
            if let error = error {
                // Handle FIDO2 SDK error
                completion(.failure(error))
            } else if let responseString = response?.raw() {
                // Step 5 – Pass FIDO2 attestation response string back to the caller.
                // The caller (FidoChallengeScreenView) will forward this to the server
                // via registrationInteractor.setUserPrompt(responseString).
                completion(.success(responseString))
            } else {
                completion(.failure(FidoRegistrationError.emptyResponse))
            }
        }
    }
    
    
}

// MARK: - Errors

enum FidoRegistrationError: LocalizedError {
    case emptyResponse
    case invalidJSON
    case cancelled

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "FIDO2 registration returned an empty response."
        case .invalidJSON:
            return "The server challenge JSON is invalid or could not be parsed."
        case .cancelled:
            return "FIDO2 registration was cancelled by the user."
        }
    }
}
// POC - End

