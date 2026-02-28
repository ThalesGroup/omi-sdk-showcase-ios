/* -----------------------------------------------------------------------------
 *
 *     Copyright (c) 2016  GEMALTO DEVELOPMENT - R&D
 *
 * ------------------------------------------------------------------------------
 * GEMALTO MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF
 * THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. GEMALTO SHALL NOT BE
 * LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 *
 * THIS SOFTWARE IS NOT DESIGNED OR INTENDED FOR USE OR RESALE AS ON-LINE
 * CONTROL EQUIPMENT IN HAZARDOUS ENVIRONMENTS REQUIRING FAIL-SAFE
 * PERFORMANCE, SUCH AS IN THE OPERATION OF NUCLEAR FACILITIES, AIRCRAFT
 * NAVIGATION OR COMMUNICATION SYSTEMS, AIR TRAFFIC CONTROL, DIRECT LIFE
 * SUPPORT MACHINES, OR WEAPONS SYSTEMS, IN WHICH THE FAILURE OF THE
 * SOFTWARE COULD LEAD DIRECTLY TO DEATH, PERSONAL INJURY, OR SEVERE
 * PHYSICAL OR ENVIRONMENTAL DAMAGE ("HIGH RISK ACTIVITIES"). GEMALTO
 * SPECIFICALLY DISCLAIMS ANY EXPRESS OR IMPLIED WARRANTY OF FITNESS FOR
 * HIGH RISK ACTIVITIES.
 *
 * ------------------------------------------------------------------------------*/
/**
 Defines REWebServiceManager.swift

 @since  13/06/16
 **/

import Foundation

private let APP_NEW_TIMEOUT: TimeInterval = 20

class REWebServiceManager: NSObject {

    // MARK: - HTTP POST

    func executeHTTPPost(_ urlString: String,
                         json jsonData: Data) {
        guard let url = URL(string: urlString) else {
            fatalError("CRASHED ON PURPOSE")
        }

        print("SERVER: OTP URL = \(urlString)")

        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration,
                                 delegate: self,
                                 delegateQueue: nil)

        var request = URLRequest(url: url)
        request.timeoutInterval = APP_NEW_TIMEOUT
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"   // constant from AppConstant

        // Trim whitespace / newlines from the JSON string before sending
        if var jsonString = String(data: jsonData, encoding: .utf8) {
            jsonString = jsonString
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .newlines)
            print("final JSON String = \(jsonString)")
            request.httpBody = jsonString.data(using: .utf8)
        } else {
            request.httpBody = jsonData
        }

        let postDataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("--RE Error Response = \(error.localizedDescription)")
            } else {
                print("--RE Response = \(String(describing: response))")

                var respDict: [AnyHashable: Any]? = nil
                if let data = data {
                    respDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
                }

                print("--RE respDict = \(String(describing: respDict))")

                if let httpResponse = response as? HTTPURLResponse {
                    print("response status code: \(httpResponse.statusCode)")
                }
            }

            session.invalidateAndCancel()
        }

        postDataTask.resume()
    }
}

// MARK: - URLSessionDelegate

extension REWebServiceManager: URLSessionDelegate {

    /// Trust the server credential for the session task (task-level challenge).
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }

    /// Trust the server credential at the session level.
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        print("--URL Session Delegate didReceiveChallenge -- \(credential)")
        completionHandler(.useCredential, credential)
    }
}
