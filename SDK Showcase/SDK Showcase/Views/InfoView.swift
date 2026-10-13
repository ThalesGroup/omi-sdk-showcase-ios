//  Copyright © 2026 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS
import UserNotifications

struct InfoView: View {
    @State private var notificationsPermissionGranted = false
    
    @ObservedObject private var app: ShowcaseApp = {
        @Injected var app: ShowcaseApp
        return app
    }()
    
    private let userClient = SharedUserClient.instance
    
    // Title with SDK version
    private var sdkVersion: String {
        if let bundle = Bundle(identifier: "com.onegini.OneginiSDKiOS"),
           let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        let bundle = Bundle(for: ConfigModel.self)
        if let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
    
    // 1. User profiles description (returns nil if empty)
    private var userProfilesDescription: String? {
        let profiles = userClient.userProfiles
        if profiles.isEmpty {
            return nil
        } else {
            return profiles.map { $0.profileId }.joined(separator: ", ")
        }
    }
    
    // 2. Authenticated user profile description (returns nil if empty)
    private var authenticatedUserDescription: String? {
        if let profile = userClient.authenticatedUserProfile {
            return profile.profileId
        }
        return nil
    }
    
    // 3. Implicitly authenticated user profile description (returns nil if empty)
    private var implicitlyAuthenticatedUserDescription: String? {
        if let profile = userClient.implicitlyAuthenticatedUserProfile {
            return profile.profileId
        }
        return nil
    }
    
    // 4. Stateless session boolean state
    private var isStatelessSession: Bool {
        userClient.isStateless
    }
    
    // 5. Registered authenticators description (returns nil if empty)
    private var registeredAuthenticatorsDescription: String? {
        let profiles = userClient.userProfiles
        if profiles.isEmpty {
            return nil
        } else {
            return profiles.map { profile in
                let registered = userClient.authenticators(.registered, for: profile)
                let names = registered.map { $0.name }.joined(separator: ", ")
                return "\(profile.profileId): \(names.isEmpty ? "None" : names)"
            }.joined(separator: "\n")
        }
    }
    
    // 6. Mobile authentication enrollment description (returns nil if empty)
    private var mobileAuthEnrollmentDescription: String? {
        let profiles = userClient.userProfiles
        if profiles.isEmpty {
            return nil
        } else {
            return profiles.map { profile in
                let enrolled = userClient.isMobileAuthEnrolled(for: profile)
                let pushEnrolled = userClient.isPushMobileAuthEnrolled(for: profile)
                
                var status = "Not enrolled"
                if enrolled && pushEnrolled {
                    status = "Enrolled (Push enabled)"
                } else if enrolled {
                    status = "Enrolled"
                } else if pushEnrolled {
                    status = "Enrolled (Push only)"
                }
                
                return "\(profile.profileId): \(status)"
            }.joined(separator: "\n")
        }
    }
    
    var body: some View {
        // Access these published properties to force SwiftUI to redraw the view and update its dynamic properties whenever the application state changes
        let _ = app.system.userState
        let _ = app.system.enrollmentState
        let _ = app.registeredUsers
        let _ = app.system.isSDKInitialized
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    StatusCard(
                        title: "SDK Initialized",
                        value: nil,
                        isBoolean: true,
                        boolValue: app.system.isSDKInitialized
                    )
                    
                    StatusCard(
                        title: "User profiles",
                        value: userProfilesDescription,
                        defaultValue: "No user profiles"
                    )
                    
                    StatusCard(
                        title: "Authenticated user profile",
                        value: authenticatedUserDescription,
                        defaultValue: "No authenticated user profile"
                    )
                    
                    StatusCard(
                        title: "Implicitly authenticated user profile",
                        value: implicitlyAuthenticatedUserDescription,
                        defaultValue: "No implicitly authenticated user profile"
                    )
                    
                    StatusCard(
                        title: "Stateless session",
                        value: nil,
                        isBoolean: true,
                        boolValue: isStatelessSession
                    )
                    
                    StatusCard(
                        title: "Registered authenticators",
                        value: registeredAuthenticatorsDescription,
                        defaultValue: "No user profiles"
                    )
                    
                    StatusCard(
                        title: "Mobile authentication enrollment",
                        value: mobileAuthEnrollmentDescription,
                        defaultValue: "No user profiles"
                    )
                    
                    StatusCard(
                        title: "Post notifications permission",
                        value: nil,
                        isBoolean: true,
                        boolValue: notificationsPermissionGranted
                    )
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("OMI SDK Status (\(sdkVersion))")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkNotificationPermissions()
            }
        }
    }
    
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsPermissionGranted = (settings.authorizationStatus == .authorized)
            }
        }
    }
}

// Custom reusable Status Card supporting default/placeholder subtitles
struct StatusCard: View {
    let title: String
    let value: String?
    var defaultValue: String? = nil
    var isBoolean: Bool = false
    var boolValue: Bool = false
    
    private var displayedValue: String? {
        if let value, !value.isEmpty {
            return value
        }
        return defaultValue
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if let displayedValue, !displayedValue.isEmpty {
                    Text(displayedValue)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            if isBoolean {
                if boolValue {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
