//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension ShowcaseApp {
    class PersistenceStore: Persistence {
        var store: KeyValueStore
        var autoinitializeSDK: Bool {
            get {
                store.value(forKey: "autoinitialize", as: Bool.self) ?? false
            }
            set {
                store.set(newValue, forKey: "autoinitialize")
            }
        }
        
        // POC - Start
        ///Extension Engine
        var fidoRegData: String {
            get {
                store.value(forKey: "poc_fido_reg_2_step", as: String.self) ?? ""
            }
            set {
                store.set(newValue, forKey: "poc_fido_reg_2_step")
            }
        }
        // POC - End
        
        init(store: KeyValueStore) {
            self.store = store
        }
    }
}
