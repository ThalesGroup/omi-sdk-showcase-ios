//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS
import SwiftUI

protocol ResourceInteractor {
    /// Requests performed on UserClient
    func sendAuthenticatedRequest()
    func sendImplicitRequest()
    func sendMultipartUpload(name: String, email: String, fileData: Data, fileName: String)
    
    /// Requests performed on UserDevice
    func sendUnauthenticatedRequest()
    func sendAnonymousRequest()
}

class ResourceInteractorReal: ResourceInteractor {
    private let userClient = SharedUserClient.instance
    private let deviceClient = SharedDeviceClient.instance
    private let decoder = JSONDecoder()
    @ObservedObject var app: ShowcaseApp

    init(app: ShowcaseApp) {
        self.app = app
    }
    
    func sendUnauthenticatedRequest() {
        // Should be defined on the access
        let pathToTheResource = "path-to-the-resource"
        let request = ResourceRequestFactory.makeResourceRequest(path: pathToTheResource)
        deviceClient.sendUnauthenticatedRequest(request) { [weak self] response, error in
            if let error {
                self?.handleError(error)
            } else {
                self?.handleData("unauthenticated request for the resource has been fetched.")
            }
        }
    }
    
    func sendAnonymousRequest() {
        let pathToTheResource = "application-details"
        
        /// First you need to collect the token
        deviceClient.authenticateDevice(with: [pathToTheResource]) { [weak self] error in
            guard error == nil else {
                self?.handleError(error!)
                return
            }
            /// We collect the token for anonymous request, proceed with the request
            let request = ResourceRequestFactory.makeResourceRequest(path: pathToTheResource)
            self?.deviceClient.sendRequest(request) { [weak self] response, error in
                if let error {
                    self?.handleError(error)
                } else {
                    if let data = response?.data {
                        if let appDetails = try? self?.decoder.decode(ApplicationDetails.self, from: data) {
                            let showable = appDetails.appId + "\n(\(appDetails.appVersion))\n\(appDetails.appPlatform)"
                            self?.handleData(showable)
                        }
                    } else {
                        self?.handleData("anonymous request for the resource has been fetched.")
                    }
                }
            }
        }
    }
    
    func sendAuthenticatedRequest() {
        let request = ResourceRequestFactory.makeResourceRequest(path: "devices", method: .get)
        userClient.sendAuthenticatedRequest(request) { [weak self] response, error in
            if let error {
                self?.handleError(error)
            } else {
                if let data = response?.data,
                   let deviceList = try? self?.decoder.decode(Devices.self, from: data) {
                   let showable = deviceList.devices.map { $0.name + " (\($0.id.truncated(10)))" }.joined(separator: "\n")
                    self?.handleData(showable)
                }
            }
        }
    }
    

    func sendImplicitRequest() {
        let request = ResourceRequestFactory.makeResourceRequest(path: "user-id-decorated", method: .get)
        userClient.sendImplicitRequest(request) { [weak self] response, error in
            if let error {
                self?.handleError(error)
            } else {
                if let data = response?.data,
                   let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let userIdDecorated = responseData["decorated_user_id"] {
                    self?.handleData(userIdDecorated)
                }
            }
        }
    }
    
    func sendMultipartUpload(name: String, email: String, fileData: Data, fileName: String) {
        guard userClient.authenticatedUserProfile != nil else {
            handleData("No authenticated user. Please log in before uploading.")
            return
        }
        guard !fileData.isEmpty else {
            handleData("Selected file is empty.")
            return
        }

        let fields: [MultipartData] = [
            MultipartField(name: "name",  text: name),
            MultipartField(name: "email", text: email),
            MultipartField(name: "attachments",
                           data: fileData,
                           fileName: fileName,
                           mimeType: mimeType(for: fileName))
        ]

        let request = ResourceRequestFactory.makeMultipartResourceRequest(
            path: "file-upload",
            method: .post,
            parameters: nil,
            multipartData: fields
        )

        userClient.sendAuthenticatedRequest(request) { [weak self] response, error in
            DispatchQueue.main.async {
                if let error {
                    self?.handleError(error)
                    return
                }
                guard let response else {
                    self?.handleData("sendMultipartUpload: no response from SDK.")
                    return
                }
                let statusCode = response.statusCode
                let bodyString = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "<non-UTF8 body>"
                if statusCode == 200 || statusCode == 201 {
                    self?.handleData("Multipart upload successful!\n\nFile: \(fileName)\nName: \(name)\nEmail: \(email)\n\n\(bodyString)")
                } else {
                    let serverError = NSError(domain: "MultipartUpload", code: statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Upload failed — HTTP \(statusCode): \(bodyString)"])
                    self?.handleError(serverError)
                }
            }
        }
    }
    
    private func mimeType(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "jpg", "jpeg": return "image/jpeg"
        case "png":         return "image/png"
        case "pdf":         return "application/pdf"
        case "txt":         return "text/plain"
        default:            return "application/octet-stream"
        }
    }
}

private extension ResourceInteractorReal {
    func handleError(_ error: Error) {
        DispatchQueue.main.async { [app] in
            app.setSystemInfo(string: error.localizedDescription)
        }
    }
    
    func handleData(_ dataString: String) {
        DispatchQueue.main.async { [app] in
            app.setSystemInfo(string: dataString)
        }
    }
}

// MARK: - MultipartData conformance

struct MultipartField: MultipartData {
    let data: Data
    let name: String
    let fileName: String
    let mimeType: String
    
    /// Plain-text form field — no filename, mimeType = text/plain
    init(name: String, text: String) {
        self.name = name
        self.data = Data(text.utf8)
        self.fileName = ""
        self.mimeType = "text/plain"
    }
    
    /// Binary / file field
    init(name: String, data: Data, fileName: String, mimeType: String) {
        self.name = name
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
