//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers

struct SheetViewForMultipartUpload: View {
    @Environment(\.dismiss) var dismiss
    @Injected private var resourceInteractor: ResourceInteractor
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var selectedFileData: Data?
    @State private var selectedFileName: String?
    @State private var showingFilePicker = false
    
    var body: some View {
        VStack {
            SheetViewDismiss()
            Form {
                Section(header: Text("Upload Details")) {
                    TextField("name", text: $name)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                    
                    TextField("email", text: $email)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Attachment")) {
                    Button(action: { showingFilePicker = true }) {
                        HStack {
                            Image(systemName: "paperclip")
                            Text(selectedFileName ?? "Pick attachment file...")
                                .foregroundStyle(selectedFileName != nil ? .primary : .secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: upload) {
                        HStack {
                            Spacer()
                            Text("Upload")
                                .bold()
                            Spacer()
                        }
                    }
                    .disabled(!isReady)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                let gotAccess = url.startAccessingSecurityScopedResource()
                defer { if gotAccess { url.stopAccessingSecurityScopedResource() } }
                selectedFileName = url.lastPathComponent
                selectedFileData = try? Data(contentsOf: url)
            }
        }
    }
    
    private var isReady: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedFileData != nil
    }
    
    private func upload() {
        guard let fileData = selectedFileData, let fileName = selectedFileName else { return }
        resourceInteractor.sendMultipartUpload(
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            fileData: fileData,
            fileName: fileName
        )
        dismiss()
    }
}
