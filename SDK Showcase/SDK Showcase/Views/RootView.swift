//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct RootView: View {
    @State private var showAlert = false
    @State private var isProcessing = false
    @ObservedObject private var app: ShowcaseApp = {
        @Injected var app: ShowcaseApp
        return app
    }()
    @ObservedObject var system: ShowcaseApp.System = {
        @Injected var app: ShowcaseApp
        return app.system
    }()
    private var interactor: CategoriesInteractor {
        @Injected var interactors: Interactors
        return interactors.categoriesInteractor
    }

    var body: some View {
        ZStack {
            TabView {
                NavigationStack(path: $app.routing.navPath) {
                    HeaderView()
                    List(interactor.loadCategories()) { category in
                        NavigationLink(value: category) {
                            Text(category.name)
                        }
                    }
                    .navigationDestination(for: Category.self) { category in
                        ContentView(category: category)
                    }
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
                InfoView()
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
            }
            .onAppear {
                if app.system.autoinitializeSDK {
                    app.system.isProcessing = true
                    app.routing.navigate(to: .initialization)
                }
            }
            
            if system.hasError {
                Alert(text: app.system.lastInfoDescription ?? "")
            }
            
            if system.isProcessing {
                Spinner()
            }
        }
    }
}
