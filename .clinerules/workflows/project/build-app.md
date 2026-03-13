# Build SDK Showcase Application

**Version:** 1.0.0  
**Platform:** iOS  
**Project:** sdk-showcase  
**Last Updated:** 2026-01-30

---

## Overview

Build the **OMI SDK Showcase App** for iOS. This workflow compiles the SwiftUI-based application demonstrating the OMI SDK integration patterns.

## Trigger Commands

- `build sdk showcase`
- `build sdk showcase app`
- `build showcase app`
- `build app`

---

## Prerequisites

- **Xcode 15.4+** installed
- **Swift 5.0+** available
- **SPM dependencies** resolved (SDKSPM from Artifactory)
- **Swinject.xcframework** available in Supporting Files
- **Valid code signing certificate** configured
- **Artifactory access** configured (`.netrc` file with credentials)

---

## Workflow Steps

### Step 1: Verify SPM Authentication

Ensure SPM registry is configured for OneWelcome private repository.

```bash
swift package-registry set --global https://thalescpliam.jfrog.io/artifactory/api/swift/swift-public --netrc
```

### Step 2: Resolve Dependencies

Resolve Swift Package Manager dependencies.

```bash
cd "SDK Showcase"
xcodebuild -resolvePackageDependencies -project "SDK Showcase.xcodeproj" -scheme "SDK Showcase"
```

### Step 3: Clean Previous Build

Clean previous build artifacts for fresh build.

```bash
xcodebuild clean \
  -project "SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -configuration Debug
```

### Step 4: Build Application (Debug)

Build the application for Debug configuration.

```bash
xcodebuild build \
  -project "SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -derivedDataPath ./build
```

**For Release build:**
```bash
xcodebuild build \
  -project "SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ./build
```

### Step 5: Verify Build Artifacts

Check that build succeeded and app bundle exists.

```bash
# For simulator (Debug)
ls -la build/Build/Products/Debug-iphonesimulator/SDK\ Showcase.app

# For device (Release)
ls -la build/Build/Products/Release-iphoneos/SDK\ Showcase.app
```

### Step 6: Display Build Summary

Show build result summary.

```bash
echo "✅ SDK Showcase build completed successfully!"
echo "Configuration: Debug"
echo "Platform: iOS Simulator"
echo "Bundle ID: com.onewelcome.omi.SDK-Showcase"
echo "Version: 1.0.1"
```

---

## Build Configurations

### Debug Configuration
- **Purpose:** Development and testing
- **Features:**
  - Debug symbols included
  - Assertions enabled
  - Optimization disabled
  - Simulator support
- **Use:** Daily development

### Release Configuration
- **Purpose:** Production deployment
- **Features:**
  - Optimized code
  - Assertions disabled
  - Code signing required
  - Device only
- **Use:** TestFlight, App Store

---

## Build Destinations

### iOS Simulator
```bash
-destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
-destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch),OS=latest'
```

### Physical Device
```bash
-destination 'generic/platform=iOS'
```

---

## Dependencies

### SDKSPM (SPM)
- **Source:** Private Artifactory repository
- **URL:** `https://thalescpliam.jfrog.io/artifactory/api/swift/swift-public`
- **Version:** 13.0.1+
- **Authentication:** `.netrc` file

### Swinject
- **Type:** XCFramework
- **Location:** `SDK Showcase/Supporting Files/Swinject.xcframework`
- **Purpose:** Dependency injection

---

## Troubleshooting

### SPM Authentication Errors

**Issue:** Package resolution fails with authentication error

**Solution:**
```bash
# Verify .netrc file exists with credentials
cat ~/.netrc

# Re-configure SPM registry
swift package-registry set --global https://thalescpliam.jfrog.io/artifactory/api/swift/swift-public --netrc

# Clear SPM cache and retry
rm -rf ~/Library/Caches/org.swift.swiftpm
```

### Code Signing Errors

**Issue:** Code signing failed

**Solution:**
1. Open project in Xcode
2. Select target "SDK Showcase"
3. Go to Signing & Capabilities
4. Verify team and certificate
5. Enable "Automatically manage signing" if needed

### Dependency Resolution Timeout

**Issue:** Package resolution times out

**Solution:**
```bash
# Increase timeout and retry
xcodebuild -resolvePackageDependencies \
  -project "SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -scmProvider system
```

### Build Errors

**Issue:** Generic build failures

**Solution:**
```bash
# Clean derived data completely
rm -rf ~/Library/Developer/Xcode/DerivedData/SDK_Showcase-*

# Clean build folder
xcodebuild clean -project "SDK Showcase.xcodeproj" -scheme "SDK Showcase"

# Rebuild
xcodebuild build -project "SDK Showcase.xcodeproj" -scheme "SDK Showcase"
```

### Swinject Framework Not Found

**Issue:** Framework not found during linking

**Solution:**
1. Verify `Swinject.xcframework` exists in `SDK Showcase/Supporting Files/`
2. Check project build phases include "Embed Frameworks"
3. Rebuild project

---

## Performance Tips

- **Parallel builds:** Xcode automatically uses multiple cores
- **Incremental builds:** Avoid `clean` unless necessary
- **Build cache:** Use DerivedData for faster rebuilds
- **Simulator:** Debug builds on simulator are faster

---

## Output Artifacts

### Debug Build
- **Location:** `build/Build/Products/Debug-iphonesimulator/`
- **App Bundle:** `SDK Showcase.app`
- **Symbols:** `.dSYM` file included

### Release Build
- **Location:** `build/Build/Products/Release-iphoneos/`
- **App Bundle:** `SDK Showcase.app`
- **Archive:** Can be exported to `.ipa`

---

## Next Steps

After successful build:
1. **Run app:** `open build/Build/Products/Debug-iphonesimulator/SDK\ Showcase.app`
2. **Run tests:** `run tests`
3. **Quality check:** `run quality checks`
4. **Commit changes:** `git commit`

---

## Related Workflows

- [run-tests](./run-tests.md) - Execute test suites
- [run-quality-checks](./run-quality-checks.md) - Code quality analysis
- [clean-build](./clean-build.md) - Clean and rebuild

---

**Maintained By:** iOS Development Team  
**Contact:** [Team Channel]
