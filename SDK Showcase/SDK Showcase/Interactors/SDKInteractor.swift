//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol SDKInteractor {
    var builder: ClientBuilder { get set }

    func initializeSDK(result: @escaping SDKResult)
    func ifpLogin()
    func resetSDK(result: @escaping SDKResult)
    func setConfigModel(_ model: SDKConfigModel)
    func setCertificates(_ certs: [String])
    func setPublicKey(_ key: String)
    func setAdditionalResourceUrls(_ url: [String])
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval)
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval)
    func setStoreCookies(_ storeCookies: Bool)
}

//MARK: - Real methods

class SDKInteractorReal: SDKInteractor {
    @ObservedObject var app: ShowcaseApp

    private static let staticBuilder = ClientBuilder()
    private var device: ShowcaseApp.DeviceData { app.deviceData }
    private var client: Client?
    var builder: ClientBuilder
    let integrator = GAHRiskEngineIntegration()
    
    init(app: ShowcaseApp, client: Client? = nil, builder: ClientBuilder = SDKInteractorReal.staticBuilder) {
        self.app = app
        self.client = client
        self.builder = builder
    }
    
    func initializeSDK(result: @escaping SDKResult) {
        integrator.startPrefetchingCollection()
        
        guard !app.system.isSDKInitialized else {
            app.setSystemInfo(string: "SDK is already initialized.")
            return
        }

        builder.buildAndWaitForProtectedData { client in
            client.start { [self] error in
                if let error {
                    return result(.failure(error))
                } else {
                    app.routing.backHome()
                    return result(.success)
                }
            }
        }
    }
    
    func ifpLogin() {
        integrator.ifpLogin()
    }
    
    func resetSDK(result: @escaping SDKResult) {
        builder.buildAndWaitForProtectedData { client in
            client.reset { [self] error in
                if let error {
                    return result(.failure(error))
                } else {
                    clearDeviceData()
                    return result(.success)
                }
            }
        }
    }

    func setPublicKey(_ key: String) {
        device.publicKey = key
        builder.setServerPublicKey(key)
    }
    
    func setConfigModel(_ model: SDKConfigModel) {
        device.model = model
        let mappedModel = mapSDKConfigModel(model)
        _ = builder.setConfigModel(mappedModel)
    }
    func setCertificates(_ certs: [String]) {
        device.certs = certs
        _ = builder.setX509PEMCertificates(certs)
    }
    
    func setAdditionalResourceUrls(_ url: [String]) {
        _ = builder.setAdditionalResourceUrls(url)
    }
    
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval) {
        _ = builder.setDeviceConfigCacheDuration(cacheDuration)
    }
    
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval) {
        _ = builder.setHttpRequestTimeout(requestTimeout)
    }
    
    func setStoreCookies(_ storeCookies: Bool) {
        _ = builder.setStoreCookies(storeCookies)
    }

    func clearDeviceData() {
        app.reset()
    }
}

//MARK: - Private Protocol Extension
private extension SDKInteractorReal {
    
    func mapSDKConfigModel(_ model: SDKConfigModel) -> OneginiSDKiOS.ConfigModel {
        // we pass here SDKConfigModel.default that contains all needed data so we are sure ConfigModel will be created
        return ConfigModel(dictionary: model.dictionary)!
    }
}
