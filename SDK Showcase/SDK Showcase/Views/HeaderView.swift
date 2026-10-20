//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack {
            Image("thales-logo")
                .resizable()
                .scaledToFit()
                .padding(-20)
            Text("Welcome to the Showcase app")
                .bold()
                .padding(.bottom, 15)
            Text("An example of the usage of the SDK, a part of the Mobile Security")
                .multilineTextAlignment(.center)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }
}
