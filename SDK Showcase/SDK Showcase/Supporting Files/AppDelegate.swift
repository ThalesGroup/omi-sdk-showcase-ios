//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import UIKit
// POC - Start
///Extension Engine
import Fido2
// POC - End

class AppDelegate: NSObject, UIApplicationDelegate {
    // POC - Start
    ///Extension Engine
    var secureLog : SecureLog!
    // POC - End
    var interactor: PushNotitificationsInteractor {
        @Injected var interactors: Interactors
        return interactors.pushInteractor
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        interactor.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        interactor.didFailToRegisterForRemoteNotificationsWithError(error)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = interactor as! PushNotitificationsInteractorReal
        // POC - Start
        ///Extension Engine
        ///Initialise SecureLog, to log necessary retrievable information.
        initializeSecureLog()
        // POC - End
        return true
    }
    
    // POC - Start
    ///Extension Engine
    private func initializeSecureLog() {
        
        //Configure SecureLog
        let config = SecureLogConfig { (slComps) in
            slComps.fileID = "fido2show"

            //Set Mandatory parameters
            slComps.publicKeyModulus = NSData(bytes: SecureLogPublicKey.publicKeyModulus, length:SecureLogPublicKey.publicKeyModulus.count) as Data
            slComps.publicKeyExponent = NSData(bytes: SecureLogPublicKey.publicKeyExponent, length: SecureLogPublicKey.publicKeyExponent.count) as Data
        }
        //create instance of secure logger with configuration, only 1 instance is allowed to be created.
        secureLog = TGFFido2Config.setupSecureLog(config)
    }
    // POC - End
}
