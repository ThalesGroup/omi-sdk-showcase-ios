//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
// POC - Start
import SwiftUI

struct FidoChallengeScreenView: View {
    @Environment(\.dismiss) var dismiss
    @Injected private var fidoRegistrationInteractor: Fido2Interactor
    @Injected private var registrationInteractor: RegistrationInteractor
    @ObservedObject private var system: ShowcaseApp.System = {
        @Injected var app: ShowcaseApp
        return app.system
    }()

    @State private var isProcessing = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            SheetViewDismiss()
            Form {
                Section(header: Text("FIDO Challenge")) {
                    Text("The following challenge data was received from the server:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if !system.fidoServerPrompt.isEmpty {
                        ScrollView {
                            Text(system.fidoServerPrompt)
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        }
                        .frame(maxHeight: 200)
                    } else {
                        Text("No challenge data received.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if let errorMessage {
                    Section(header: Text("Error")) {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }

                Section {
                    Button(action: {
                        if system.isFidoRegistration {
                            submitFidoRegistration()
                        } else {
                            submitFidoAuthentication()
                        }
                        
                    }) {
                        HStack {
                            Spacer()
                            if isProcessing {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("Processing...")
                                    .bold()
                            } else {
                                Text(system.isFidoRegistration ? "Submit" : "Authenticate")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(system.fidoServerPrompt.isEmpty || isProcessing)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    /// Extracts the FIDO2 CredentialCreationOptions JSON string from the
    /// server's response payload.
    ///
    /// The server wraps the FIDO2 payload inside a JSON object. This method
    /// looks for the `fido2` key first, then falls back to `publicKey`, and
    /// finally returns the raw string if no known wrapper key is found.
    ///
    /// - Parameter rawJSON: The full JSON string received from the server.
    /// - Returns: The FIDO2-specific JSON string to pass to the SDK.
    private func extractFido2Value(from rawJSON: String) -> String? {
        guard
            let data = rawJSON.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: dict["fido2"],
                options: [.prettyPrinted] // optional
            )
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Failed to convert dictionary to JSON: \(error)")
        }

        // No known wrapper key — return the raw JSON string as-is
        return rawJSON
    }
    
    /// Initiates FIDO2 registration using the extracted FIDO2 value from the
    /// server challenge JSON, then forwards the attestation response back to the server.
    private func submitFidoAuthentication() {
        let rawJSON = system.fidoServerPrompt

        // Parse and extract the FIDO2-specific value from the server JSON
        guard let fido2JSONString = extractFido2Value(from: rawJSON) else {
            errorMessage = "Failed to parse the server challenge JSON."
            return
        }

        isProcessing = true
        errorMessage = nil

        fidoRegistrationInteractor.register(with: fido2JSONString) { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success(let responseString):
                    // Pass the FIDO2 attestation response back to the server
                    // via the custom registration challenge handler.
                    registrationInteractor.setFidoUserPrompt(responseString)
                    system.setFidoChallengeState(.hidden)
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    fidoRegistrationInteractor.setUserPrompt("fail")
                }
            }
        }
    }

    /// Initiates FIDO2 registration using the extracted FIDO2 value from the
    /// server challenge JSON, then forwards the attestation response back to the server.
    private func submitFidoRegistration() {
        let rawJSON = system.fidoServerPrompt

        // Parse and extract the FIDO2-specific value from the server JSON
        guard let fido2JSONString = extractFido2Value(from: rawJSON) else {
            errorMessage = "Failed to parse the server challenge JSON."
            return
        }

        isProcessing = true
        errorMessage = nil

        fidoRegistrationInteractor.register(with: fido2JSONString) { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success(let responseString):
                    // Pass the FIDO2 attestation response back to the server
                    // via the custom registration challenge handler.
//                    fidoRegistrationInteractor.setUserPrompt(responseString)
                    registrationInteractor.setFidoUserPrompt(responseString)
                    system.setFidoChallengeState(.hidden)
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    fidoRegistrationInteractor.setUserPrompt(errorMessage ?? "fail")
                }
            }
        }
    }
}
// POC - End
