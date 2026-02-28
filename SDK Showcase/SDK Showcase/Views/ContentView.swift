//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var app: ShowcaseApp = {
        @Injected var app: ShowcaseApp
        return app
    }()
    @ObservedObject var system: ShowcaseApp.System = {
        @Injected var app: ShowcaseApp
        return app.system
    }()

    @State internal var category: Category
    @State internal var isExpanded = false
    @State internal var actions = [Action]()
    @State internal var errorValue = ""
    @State internal var showConfirmationDialog = false
    @State internal var selectedOption: Selection?
    
    var body: some View {
        HStack {
            List {
                Text(category.description)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                if !category.requiredActions.isEmpty {
                    Section(header: Text("Required Actions")) {
                        ForEach(category.requiredActions, id:\.self) { action in
                            ActionView(action: binding(for: action))
                        }
                    }
                }
                
                if !category.optionalActions.isEmpty {
                    Section(header: Text("Optional Actions")) {
                        ForEach(category.optionalActions, id:\.self) { action in
                            ActionView(action: binding(for: action))
                        }
                    }
                }
                
                if !category.selections.isEmpty {
                    Section(header: Text("Select")) {
                        ForEach(category.selections, id:\.self) { selection in
                            Button(action: {
                                buttonAction(for: selection)
                            }, label: {
                                HStack {
                                    if let logo = selection.logo {
                                        Image(systemName: logo)
                                    }
                                    Text(selection.name.truncated())
                                }
                            }).disabled(selection.disabled)
                        }
                    }
                    if showConfirmationDialog {
                        if category.type == .pendingTransactions {
                            PendingTransactionConfirmationSheet(showConfirmationDialog: $showConfirmationDialog, selectedOption: selectedOption)
                        } else {
                            AuthenticatorsSheet(showConfirmationDialog: $showConfirmationDialog, selectedOption: selectedOption)
                        }
                    }
                }
                
                Section(content: {
                    TextResult(result: initializationStatus)
                    TextResult(result: userStateDescription)
                    if case .authenticated = system.userState {
                        TextResult(result: enrollmentStateDescription)
                    }
                }, header: {
                    Text("Result")
                })
            }
            .listStyle(.insetGrouped)
            .shadow(radius: 5, x: 0, y: 5)
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $system.shouldShowBrowser) {
            SheetViewForWebView(urlString: setupSheetViewForWebview())
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $system.shouldShowPinPad) {
            SheetViewForPinPad()
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $system.shouldShowScanner) {
            SheetViewForQRScanner()
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $system.shouldShowPrompt) {
            SheetViewForPrompt()
                .interactiveDismissDisabled()
        }
        .onChange(of: app.registeredUsers) {
            updateUsersSelection()
            updateDeregister()
        }
        .onChange(of: app.system.enrollmentState) {
            updateMobileAuthenticationCategorySelection()
        }
        .onChange(of: app.pendingTransactions) {
            pendingTransactionsTask()
        }
        .onChange(of: app.system.userState) {
            updateLogout()
        }
        .task {
            updateTokens()
            updateUsersSelection()
            updateIdentityProviders()
            updateLogout()
            updateDeregister()
            updateMobileAuthenticationCategorySelection()
            pendingTransactionsTask()
            guard app.system.autoinitializeSDK else { return }
            initializeSDK(automatically: true)
        }
        
        HStack {
            ForEach(category.options) { option in
                Button(action: {
                    buttonAction(for: option)
                }, label: {
                    HStack {
                        if let logo = option.logo {
                            Image(systemName: logo)
                        }
                        Text(option.name)
                    }
                })
                .padding()
            }
        }
    }
}

//MARK: - Actions
extension ContentView {

    func buttonAction(for option: Option) {
        system.isProcessing = true
        
        switch option.type {
        case .initialize:
            initializeSDK(automatically: false)
        case .autoinitialize:
            initializeSDK(automatically: true)
        case .ifpLogin:
            ifpLogin()
        case .reset:
            resetSDK()
        case .changePin:
            changePIN()
        case .enroll:
            enrollForMobileAuthentication()
        case .pushes:
            registerForPushes()
        case .registerAuthenticator:
            registerAuthenticator()
        case .cancel:
            cancelRegistration()
        case .sso:
            sso()
        default:
            fatalError("Option `\(option.name)` not handled!")
        }
    }
    
    func buttonAction(for selection: Selection) {
        let switcher = selection.type == .unknown ? selection.namedType : selection.type
        
        switch switcher {
        case .register:
            startRegistration(authenticatorName: selection.name)
        case .loginWithOtp:
            authenticatorInteractor.loginWithOTP()
        case .pending, .authenticate:
            selectedOption = selection
            selectedOption?.disabled = !value(for: "Implicitly")
            showConfirmationDialog = true
        case .logout:
            authenticatorInteractor.logout(optionName: selection.name)
        case .deregister:
            registrationInteractor.deregister(optionName: selection.name)
        case .token:
            authenticatorInteractor.showToken(selection.name)
        case .authenticatedRequest:
            sendAuthenticatedRequest()
        case .unauthenticatedRequest:
            sendUnauthenticatedRequest()
        case .implicitRequest:
            sendImplicitRequest()
        case .anonymousRequest:
            sendAnonymousRequest()
        case .unknown:
            fatalError("Selection `\(selection.name)` not handled!")
        }
    }
    
    func setupSheetViewForWebview() -> String {
        var urlStringForWebview = ""
        switch system.userState {
        case .registering:
            urlStringForWebview = registrationInteractor.registerUrl
        case .sso(let url):
            urlStringForWebview = url
        default:
            break
        }
        return urlStringForWebview
    }
}
