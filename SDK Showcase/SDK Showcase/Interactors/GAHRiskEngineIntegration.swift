/* ----------------------------------------------------------------------------
 *
 *     Copyright (c) 2018  -  GEMALTO DEVELOPEMENT - R&D
 *
 * -----------------------------------------------------------------------------
 * GEMALTO MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF
 * THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. GEMALTO SHALL NOT BE
 * LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 *
 * THIS SOFTWARE IS NOT D&ESIGNED OR INTENDED FOR USE OR RESALE AS ON-LINE
 * CONTROL EQUIPMENT IN HAZARDOUS ENVIRONMENTS REQUIRING FAIL-SAFE
 * PERFORMANCE, SUCH AS IN THE OPERATION OF NUCLEAR FACILITIES, AIRCRAFT
 * NAVIGATION OR COMMUNICATION SYSTEMS, AIR TRAFFIC CONTROL, DIRECT LIFE
 * SUPPORT MACHINES, OR WEAPONS SYSTEMS, IN WHICH THE FAILURE OF THE
 * SOFTWARE COULD LEAD DIRECTLY TO DEATH, PERSONAL INJURY, OR SEVERE
 * PHYSICAL OR ENVIRONMENTAL DAMAGE ("HIGH RISK ACTIVITIES"). GEMALTO
 * SPECIFICALLY DISCLAIMS ANY EXPRESS OR IMPLIED WARRANTY OF FITNESS FOR
 * HIGH RISK ACTIVITIES.
 *
 * -----------------------------------------------------------------------------
 */

import Foundation
import CommonCrypto
import CoreLocation
import GAHRiskEngine

class GAHRiskEngineIntegration: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    /**
     * STEP 1: Create Configuration objects
     * STEP 2 : Initialize GAHRiskEngine
     * This method will taken care for creating configuration objects and GAHRiskEngineSDK Inilizations.
     */
    override init() {
        super.init()
        
        locationManager.delegate = self
        
        /*Set EAH Backend URL*/
        let bundle:Bundle = Bundle.init(for: GAHRiskEngineIntegration.self)
        let path:String = bundle.path(forResource: "Info", ofType: "plist")!
        let signalConnectionDict:NSMutableDictionary = NSMutableDictionary.init(contentsOfFile: path)!
        let eahUrl:String = signalConnectionDict.value(forKey: "REBackendUrl") as! String
        
        //Create GAHCoreConfig object
        let reConfig:GAHCoreConfig = GAHCoreConfig.sharedConfiguration(withUrl: eahUrl)
        
       
        //Create GAHGemaltoSignalConfig object
        let signalConfig:GAHGemaltoSignalConfig = GAHGemaltoSignalConfig.sharedConfiguration()

        //Create GAHTMXConfig object
        let orgID:String = signalConnectionDict.value(forKey: "TMXOrgId") as! String
        let ftpServer:String = signalConnectionDict.value(forKey: "FTPServer") as! String
        let tmxConfig:GAHTMXConfig = GAHTMXConfig.sharedConfiguration(withOrgID: orgID, andFingerprintServer: ftpServer)
        
        let tmxValidCertificatePath = Bundle.main.url(forResource: "h-sdk.online-metrix.net", withExtension: "cer")
        let tmxValidCertificateData = NSData.init(contentsOf: tmxValidCertificatePath!)! as Data

        let profilingConnections : TMXProfilingConnections = TMXProfilingConnections.init()
        profilingConnections.connectionTimeout    = 20
        profilingConnections.connectionRetryCount = 2
        profilingConnections.certificateHashArray = [self.sha256(data: tmxValidCertificateData)]
        tmxConfig.profilingConnectionsInstance = profilingConnections
        
        let coreSet: Set<GAHConfig> = [reConfig,signalConfig,tmxConfig];

        #if DEBUG

        #else
          //  To set SSL certificates uncomment below 2 lines
    
           let pathToCert:String = Bundle.main.path(forResource: "gemalto_Demo_server", ofType: "cer")!
    
            do {
               let certificatedata:NSData = try NSData.init(contentsOfFile: pathToCert)
               self.configureCertifcate(certificates: NSArray.init(objects: certificatedata))
           }
           catch let error as NSError{
               print(error.description)
           }
    
    
        #endif
    
        //STEP2 : Initialize GAHRiskEngine with all Configs
        GAHCore.initialize(coreSet)
        
        let metaInfo:GAHMetaInformation = GAHMetaInformation.init();
        NSLog("Build Name = %@", metaInfo.getName())
        NSLog("Build version = %@", metaInfo.getVersion())
        NSLog("Build  = %@", metaInfo.getBuild())
        NSLog("Build isDebug = %d", metaInfo.isDebugMode())

    }
    
    /**
     * STEP3: Initiate prefetching of signals from all providers before the actual signal collection.
     * This enhances the signal collection time during the actual login
     */
    
    func startPrefetchingCollection() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            // Authorization always granted, safe to proceed
            GAHCore.startPrefetchSignals()
            
            checkIn5()
        case .denied, .restricted:
            // Location not available, but still call prefetch (it may work without location)
            break
        @unknown default:
            break
        }
    }
    
    func ifpLogin() {
       print("IFP LOGIN NOW")
        
        let webManager = REWebServiceManager()
        GAHCore.requestVisitID { visitId in
            guard let visitId = visitId else {
                fatalError("NO VISIT ID")
            }
            let loginUrl = "https://demo-ebanking.rnd.gemaltodigitalbankingidcloud.com/api/v1/tenants/cloudtenant/visits/\(visitId)/login"
            print(loginUrl)
            
            let json = [
                "step": "userIdAndPassword",
                "userId": "testUser",
                "password": "pwd",
                "actionId": UIDevice.current.identifierForVendor!.uuidString,
                "actionToUse": "getDecision"
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: json)
            webManager.executeHTTPPost(loginUrl,
                                       json: jsonData)
        } failure: { errorCode, errorMessage in
            print("Failed to get visitId with errorCode: \(errorCode), \(errorMessage ?? "")")
        }

    }
    
    func checkIn5() {
        // check profile status of ThreatMetrxi by calling below method
        //This API will give profile status immedialty if ThreatMetrix is completed else call back will come after 5 seconds with status
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5, execute: { [weak self] in
            self?.signalPrefetchStatus { (statusCode, statusMessage) in
                print("requestPrefetchStatus response from GAH is statusCode == ",statusCode, "and StatusMessage == ",statusMessage!)

                DispatchQueue.main.async {
                    if statusCode == PREFETCH_STATUS_OK {
                        print("PREFETCH_STATUS_OK")
                    } else {
                        print("PREFETCH_STATUS_NOK")
                    }
                    self?.step7()
                }
            }
        })
    }
    
    func step7() {
        requestVisitID(succesHandler: { (visitId) in
            print("response from GAHSDK == \(self.requestJson())")
            print("Request complete, go ahead with login immediately")
        }) { (errorCode, errorMessage) in
            print("error: \(errorMessage)")
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
 
        // Now that authorization status has been determined, start prefetch
        startPrefetchingCollection()
    }
 
    
    /**
     * STEP5: Request for signal prefetch status
     * @param callback Callback to get the status when prefetch is completed.
     */
    func signalPrefetchStatus(prefetchStatus:@escaping GAHPrefetechStatus) {
        
        GAHCore.requestPrefetchStatus { (prefetchStatusCode, prefetchStatusMessage) in
            print("requestPrefetchStatus response from GAH is statusCode == ",prefetchStatusCode, "and StatusMessage == ",prefetchStatusMessage ?? "error")
            
            prefetchStatus(prefetchStatusCode,prefetchStatusMessage)
            
        }
    }
    
    /**
     * STEP7:Request Visit ID value from GAHRiskEngine
     * This method is used to request Visit ID value from GAHRiskEngine. In this Method Communication with RESDK will happen to fetch visit ID
     * @param succesHandler Callback instance to get Visit ID
     * @param failHandler Indicates failure instance
     */
    func requestVisitID(succesHandler:@escaping GAHSuccessHandler, failHandler:@escaping GAHFailureHandler) {

      
        
        GAHCore.requestVisitID({ (visitId) in
            print("visit id in GAH == %@",visitId ?? "default");
            print("json in app == \(GAHCore.getSignalValuesJson())")
            succesHandler(visitId)
        }) { (errorCode, errorMessage) in
            print("visit error in GAH == %@",errorMessage ?? "default");
            failHandler(errorCode,errorMessage)
        }
        
    }
    
    
    func requestJson() -> Void {
        
        print("json in app == \(GAHCore.getSignalValuesJson())")
    }
    
    
    
    
    /**
     * STEP11: Stop prefetch collection
     * stopPrefetchingCollections - Stops all provider signal collection prefetch
     */
    func stopPrefetchingCollections() {
        
        /* Fire off the stopPrefetchingCollections request. */
        GAHCore.stopPrefetchSignals()
    }
    
    
    /**
     * Setting a transaction as critical will update the cached values with new values.
     * This API can be called while performing a critical transaction, i.e when a screen with critical transaction is
     * launched so that all old signal values in the cache are force refreshed.
     * Currently caching of Signal values are supported for ThreatMetrix alone hence
     * call this API if ThreatMetrix is initialized.
     * This API should be used as a substitute to GAHCore.startPrefetchSignals() as the latter will try to fetch the
     * value from the cache.
     */
    func setTransactionAsCritical() {
        
        GAHCore.setTransactionAsCritical()
    }
    
    /**
     * Method to configure certificates and TLS configurations to GAHRiskEngine
     * This will be used for establishing a secure connection between GAHRiskEngine and RE backend
     * Kindly request for the URL specific certificate from Gemalto.
     * @param certificates array with valid certifates data
     */
    func configureCertifcate(certificates:NSArray) {
        
        /* set config object */
        let reConfig:GAHCoreConfig = GAHCoreConfig.getsharedConfigManagerObject()
        var tlsconfiguration:GAHTLSConfiguration = GAHTLSConfiguration.init()
        
        #if DEBUG
        
        tlsconfiguration.hostnameMismatchAllowed = true
        tlsconfiguration.selfSignedCertAllowed = true
        tlsconfiguration.insecureConnectionAllowed = true
        
        
        #else
        
        tlsconfiguration.selfSignedCertAllowed = true
        #endif
                
        reConfig.grestlsConfiguration(certificates as? [Any] , withRESDKTLSConfiguration: tlsconfiguration)
        
    }
    
    func sha256(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).map { String(format: "%02hhx", $0) }.joined()
    }
}
