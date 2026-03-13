//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

protocol MobileAuthRequestInteractor {
    var isMobileAuthEnrolled: Bool { get }

    func handlePushMobileAuthenticationRequest(userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void)
    func handleOtp(_ code: String)
    func handlePendingTransaction(id: String, confirmed: Bool)
    func fetchPendingTransactionNames() async -> [String]
    func fetchEnrollment()
    func enrollForMobileAuthentication()
}

class MobileAuthRequestInteractorReal: MobileAuthRequestInteractor {
    private let userClient = SharedUserClient.instance
    private var entityToBeConfirmed: MobileAuthRequestEntity?
    @ObservedObject var app: ShowcaseApp

    init(app: ShowcaseApp) {
        self.app = app
    }
    
    func enrollForMobileAuthentication() {
        guard precheck() else { return }
        userClient.enrollMobileAuth { [self] error in
            app.system.isProcessing = false
            if let error {
                app.setSystemInfo(string: error.localizedDescription)
            } else {
                app.system.setEnrollmentState(.mobile)
                app.setSystemInfo(string: "User successfully enrolled for mobile authentication!")
            }
        }
    }

    func fetchEnrollment() {
        if isMobileAuthEnrolled {
            app.system.setEnrollmentState(.mobile)
        }
        if isPushRegistered {
            app.system.setEnrollmentState(.push)
        }
    }
    
    func fetchPendingTransactionNames() async -> [String] {
        guard precheck() else { return [] }
        guard isMobileAuthEnrolled else {
            app.setSystemInfo(string: "You are not enrolled for mobile authentication. Please enroll first!")
            return []
        }
        app.system.isProcessing = true

        return await withCheckedContinuation { continuation in
            userClient.pendingPushMobileAuthRequests { [self] requests, error in
                app.system.isProcessing = false
                guard let requests else {
                    pushInteractor.updateBadge(0)
                    continuation.resume(returning: [])
                    return
                }
                for request in requests {
                    app.pendingTransactions.insert(PendingMobileAuthRequestEntity(pendingTransaction: request))
                }
                let requestsToReturn = requests.compactMap(\.transactionId)
                continuation.resume(returning: requestsToReturn)
                pushInteractor.updateBadge(requestsToReturn.count)
            }
        }
    }
    
    func handleOtp(_ code: String) {
        guard userClient.canHandleOTPMobileAuthRequest(otp: code) else {
            app.setSystemInfo(string: "Invalid otp code or previous request in progress.")
            return
        }
        userClient.handleOTPMobileAuthRequest(otp: code, delegate: self)
    }
    
    func handlePushMobileAuthenticationRequest(userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        guard let pendingTransaction = userClient.pendingMobileAuthRequest(from: userInfo) else {
            app.setSystemInfo(string: "Push notification not handled. User is not authenticated most likely.")
            return
        }
        
        let mobileAuthRequest = PendingMobileAuthRequestEntity(pendingTransaction: pendingTransaction, delegate: self)
        app.pendingTransactions.insert(mobileAuthRequest)
        app.routing.navigate(to: .pendingTransactions)
    }
    
    func handlePendingTransaction(id: String, confirmed: Bool) {
        guard let transaction = pendingTransaction(id: id),
              let pendingRequestProxy = transaction.pendingTransaction else {
            return
        }
        transaction.isConfirmed = confirmed
        app.system.isProcessing = true
        userClient.handlePendingMobileAuthRequest(pendingRequestProxy, delegate: self)
    }
    
    func confirmTransaction(for entity: MobileAuthRequestEntity, automatically: Bool) {
        entityToBeConfirmed = entity
        if automatically {
            handleEntity(entity)
        } else {
            handleChallengeForEntity(entity)
        }
    }
    
    func handleEntity(_ entity: MobileAuthRequestEntity) {
        defer {
            pushInteractor.updateBadge(nil)
        }
        guard let transactionId = entity.transactionId, let transaction = pendingTransaction(id: transactionId) else {
            entity.confirmation?(false)
            app.setSystemInfo(string: "There is no transaction to confirm.")
            entityToBeConfirmed = nil
            return
        }

        entity.confirmation?(transaction.isConfirmed)
        app.setSystemInfo(string: "The transaction with message:\n\n\"\(entity.message ?? "")\"\n\n\(transaction.isConfirmed ? "✅ has been confirmed" : "❌ has been declined").")
        app.pendingTransactions.remove(transaction)
    }
    
    func handleChallengeForEntity(_ entity: MobileAuthRequestEntity) {
        defer {
            pushInteractor.updateBadge(nil)
        }
        guard let transactionId = entity.transactionId, let transaction = pendingTransaction(id: transactionId) else {
            entity.confirmation?(false)
            app.setSystemInfo(string: "There is no transaction to confirm.")
            entityToBeConfirmed = nil
            return
        }
        
        switch entity.authenticatorType {
        case .pin:
            guard let pinChallenge = entity.pinChallenge else { return }
            if transaction.isConfirmed {
                pinPadInteractor.setPinChallenge(pinChallenge)
                pinPadInteractor.showPinPad(for: .authenticating)
            } else {
                pinChallenge.sender.cancel(pinChallenge)
                app.removePendingTransaction(transactionId: transactionId)
                entityToBeConfirmed = nil
            }
        case .biometric:
            guard let biometricChallenge = entity.biometricChallenge else { return }
            if transaction.isConfirmed {
                biometricChallenge.sender.respond(with: "User authentication", to: biometricChallenge)
            } else {
                biometricChallenge.sender.cancel(biometricChallenge)
                app.removePendingTransaction(transactionId: transactionId)
                entityToBeConfirmed = nil
            }
        case .custom:
            guard let customAuthChallenge = entity.customAuthChallenge else { return }
            if transaction.isConfirmed {
                customAuthChallenge.sender.respond(with: entity.data, to: customAuthChallenge)
            } else {
                customAuthChallenge.sender.cancel(customAuthChallenge, underlyingError: customAuthChallenge.error)
                app.removePendingTransaction(transactionId: transactionId)
                entityToBeConfirmed = nil
            }
        default:
            app.setSystemInfo(string: "The transaction should be authenticated first.")
        }
    }
    
    func pendingTransaction(id: String) -> PendingMobileAuthRequestEntity? {
        app.pendingTransactions.first { $0.pendingTransaction?.transactionId == id }
    }
    
    var isMobileAuthEnrolled: Bool {
        guard let profileId = app.system.userState.userId,
              userClient.isMobileAuthEnrolled(for: UserProfileImplementation(profileId: profileId)) else {
            return false
        }
        
        return true
    }
    
    var isPushRegistered: Bool {
        guard let profileId = app.system.userState.userId,
              userClient.isPushMobileAuthEnrolled(for: UserProfileImplementation(profileId: profileId)) else {
            return false
        }
        
        return true
    }
    
    func precheck() -> Bool {
        let stateless = userClient.isStateless && userClient.accessToken != nil
        let check = userClient.authenticatedUserProfile != nil && userClient.accessToken != nil
        
        guard !stateless else {
            app.setSystemInfo(string: "Stateless user cannot proceed.")
            return false
        }
        
        if !check {
            app.setSystemInfo(string: "You must be authenticated first.")
        }
        
        return check
    }
}

private extension MobileAuthRequestInteractorReal {
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    
    var pushInteractor: PushNotitificationsInteractor {
        @Injected var interactors: Interactors
        return interactors.pushInteractor
    }
}
    
extension MobileAuthRequestInteractorReal: MobileAuthRequestDelegate {
    func userClient(_ userClient: any UserClient, didReceiveCustomAuthFinishAuthenticationChallenge challenge: any CustomAuthFinishAuthenticationChallenge, for request: any MobileAuthRequest) {
        let mobileAuthEntity = MobileAuthRequestEntity()
        mobileAuthEntity.message = request.message
        mobileAuthEntity.transactionId = request.transactionId
        mobileAuthEntity.userProfile = request.userProfile
        mobileAuthEntity.authenticatorType = .custom
        mobileAuthEntity.customAuthChallenge = challenge
        mobileAuthEntity.data = DummyData.customAuthFinishRegistrationChallenge

        confirmTransaction(for: mobileAuthEntity, automatically: false)
    }
    
    func userClient(_ userClient: UserClient, didReceiveConfirmation confirmation: @escaping (Bool) -> Void, for request: MobileAuthRequest) {
        let mobileAuthEntity = MobileAuthRequestEntity()
        mobileAuthEntity.message = request.message
        mobileAuthEntity.transactionId = request.transactionId
        mobileAuthEntity.userProfile = request.userProfile
        mobileAuthEntity.authenticatorType = .confirmation
        mobileAuthEntity.confirmation = confirmation
        
        confirmTransaction(for: mobileAuthEntity, automatically: true)
    }
    
    func userClient(_ userClient: any UserClient, didReceiveBiometricChallenge challenge: any BiometricChallenge, for request: any MobileAuthRequest) {
        let mobileAuthEntity = MobileAuthRequestEntity()
        mobileAuthEntity.message = request.message
        mobileAuthEntity.transactionId = request.transactionId
        mobileAuthEntity.userProfile = request.userProfile
        mobileAuthEntity.authenticatorType = .biometric
        mobileAuthEntity.biometricChallenge = challenge
        
        confirmTransaction(for: mobileAuthEntity, automatically: false)
    }
    
    func userClient(_ userClient: any UserClient, didReceivePinChallenge challenge: any PinChallenge, for request: any MobileAuthRequest) {
        let mobileAuthEntity = MobileAuthRequestEntity()
        mobileAuthEntity.message = request.message
        mobileAuthEntity.transactionId = request.transactionId
        mobileAuthEntity.userProfile = request.userProfile
        mobileAuthEntity.authenticatorType = .pin
        mobileAuthEntity.pinChallenge = challenge
        
        confirmTransaction(for: mobileAuthEntity, automatically: false)
    }

    func userClient(_ userClient: any UserClient, didFailToHandleRequest request: any MobileAuthRequest, authenticator: Authenticator?, error: any Error) {
        app.setSystemInfo(string: error.localizedDescription)
        pushInteractor.updateBadge(nil)
    }
    
    func userClient(_ userClient: any UserClient, didHandleRequest request: any MobileAuthRequest, authenticator: Authenticator?, info customAuthenticatorInfo: (any CustomInfo)?) {
        guard let entityToBeConfirmed, let transactionId = entityToBeConfirmed.transactionId else { return }
        
        pinPadInteractor.showPinPad(for: .hidden)
        app.setSystemInfo(string: "The transaction with message:\n\n\"\(entityToBeConfirmed.message ?? "")\"\n\n✅ has been confirmed.")
        app.removePendingTransaction(transactionId: transactionId)
        pushInteractor.updateBadge(nil)
        self.entityToBeConfirmed = nil
    }
}
