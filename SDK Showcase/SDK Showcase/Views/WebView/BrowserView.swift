//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import WebKit

struct BrowserView: View {
    @StateObject var browserViewModel: BrowserViewModel
    @Binding var isLoading: Bool
    @Binding var errorString: String
    @Binding var redirectURL: URL?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                TextField("URL", text: $browserViewModel.urlString, onCommit: {
                    browserViewModel.loadURLString()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(true)
                
                Button(action: {
                    browserViewModel.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .tint(.black)
                }
            }
            .padding(.vertical)
            if let url = URL(string: browserViewModel.urlString) {
                BrowserWebView(viewModel: browserViewModel, url: url)
                    .onChange(of: browserViewModel.isFinished) { isLoading = false }
                    .onChange(of: browserViewModel.errorMessage) { errorString = $1 }
                    .onChange(of: browserViewModel.rediredURL) { redirectURL = $1; dismiss() }
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct BrowserWebView: UIViewRepresentable {
    @ObservedObject var viewModel: BrowserViewModel
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        viewModel.webView = webView
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
