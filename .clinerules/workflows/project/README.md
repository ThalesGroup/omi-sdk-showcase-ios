# SDK Showcase Workflows

**Platform:** iOS  
**Project:** sdk-showcase  
**Type:** Application  
**Version:** 1.0.0

---

## Overview

Workflows for building, testing, and maintaining the **OMI SDK Showcase App** - a comprehensive demonstration of OMI SDK integration patterns built with SwiftUI.

## Project Information

- **Full Name:** OMI SDK Showcase App
- **Description:** Fully featured demonstration of the OMI SDK for iOS, showcasing authentication, session management, and SDK integration patterns
- **Platform:** iOS 17.5+
- **Language:** Swift 5.0
- **UI Framework:** SwiftUI
- **Build System:** Xcode 15.4+
- **Dependencies:** SDKSPM (SPM), Swinject (XCFramework)
- **Bundle ID:** com.onewelcome.omi.SDK-Showcase
- **Version:** 1.0.1

---

## Available Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| [build-app](./build-app.md) | `build sdk showcase`, `build app` | Build iOS application for simulator or device |
| [run-tests](./run-tests.md) | `run tests`, `test app` | Execute unit tests with coverage |
| [run-quality-checks](./run-quality-checks.md) | `run quality checks` | SwiftLint analysis and static analyzer |
| [clean-build](./clean-build.md) | `clean build`, `rebuild` | Clean and rebuild from scratch |

---

## Architecture

The SDK Showcase uses a modular architecture with clear separation of concerns:

### Core Components

- **ShowcaseApp** - Main app coordinator with feature extensions
- **Interactors** - Business logic layer (11 interactors)
- **Views** - SwiftUI UI layer (14+ views)
- **Models** - Data models (16 models)
- **States** - State management (5 state objects)
- **DI** - Swinject dependency injection
- **Helpers** - Utilities and extensions

### Key Patterns

- **Dependency Injection** - Swinject for loose coupling
- **Interactor Pattern** - Business logic separation
- **State Management** - Dedicated state objects
- **Feature Extensions** - Modular ShowcaseApp+* files
- **Protocol-Oriented** - Testable interactor protocols

---

## Common Workflow Sequences

### Development Cycle
```bash
1. build sdk showcase
2. run tests
3. git commit
```

### Quality Check Before Merge
```bash
1. run quality checks
2. run tests
3. build sdk showcase
```

### Fixing Build Issues
```bash
1. clean build
2. run tests
3. run quality checks
```

### Full CI Pipeline
```bash
1. clean build
2. run quality checks
3. run tests
4. build sdk showcase (Release)
```

---

## Dependencies

### SDKSPM (Primary)
- **Type:** Swift Package Manager
- **Source:** Private Artifactory (OneWelcome)
- **URL:** `https://thalescpliam.jfrog.io/artifactory/api/swift/swift-public`
- **Version:** 13.0.1+
- **Authentication:** `.netrc` file with credentials
- **Purpose:** Core OMI SDK functionality

### Swinject
- **Type:** XCFramework (embedded)
- **Location:** `SDK Showcase/Supporting Files/Swinject.xcframework`
- **Purpose:** Dependency injection container
- **Integration:** Copied into app bundle with code signing

---

## Build Configurations

### Debug
- **Use:** Daily development
- **Features:** Debug symbols, assertions enabled
- **Target:** iOS Simulator
- **Build Time:** ~2-3 minutes

### Release
- **Use:** Production, TestFlight, App Store
- **Features:** Optimized code, no assertions
- **Target:** iOS Device
- **Build Time:** ~3-5 minutes

---

## Test Coverage

### Test Target: SDK ShowcaseTests
- **CategoriesInteractorTest** - Category management tests
- **ModelTests** - Data model validation
- **SDKInteractorTest** - SDK integration tests
- **Mocks/** - Test doubles for dependencies

### Coverage Goals
- **Unit Tests:** >70% line coverage
- **Interactors:** 100% coverage
- **Models:** 100% coverage

---

## Quality Standards

### SwiftLint Rules
- **Max Line Length:** 140 characters
- **Max File Length:** 500 lines
- **Max Type Body:** 300 lines
- **Naming:** Swift API Design Guidelines
- **Force Unwrap:** Errors (not allowed)
- **Force Cast:** Errors (not allowed)

### Acceptance Criteria
✅ 0 SwiftLint errors  
✅ <10 SwiftLint warnings  
✅ All tests passing  
✅ >70% code coverage  
✅ Clean static analysis  

---

## Prerequisites

### Required Tools
- **Xcode 15.4+** - Primary IDE
- **Swift 5.0+** - Language version
- **SwiftLint** - Code quality (`brew install swiftlint`)
- **jq** - JSON parsing (optional, `brew install jq`)

### Required Setup
- **Artifactory Access** - Credentials configured in `.netrc`
- **SPM Registry** - Configured with authentication
- **Code Signing** - Valid certificate and provisioning profile
- **iOS Simulator** - At least one available simulator

### Environment Setup
```bash
# Configure SPM registry
swift package-registry set --global https://thalescpliam.jfrog.io/artifactory/api/swift/swift-public --netrc

# Install SwiftLint
brew install swiftlint

# Verify setup
xcodebuild -version
swift --version
swiftlint version
```

---

## Troubleshooting

### Common Issues

**Build Failures**
- Try: `clean build`
- Check: SPM authentication
- Verify: Swinject.xcframework exists

**Test Failures**
- Try: Reset simulators
- Check: Dependencies resolved
- Verify: Test target configured

**Quality Check Failures**
- Install: `brew install swiftlint`
- Check: `.swiftlint.yml` exists
- Review: SwiftLint rules

**SPM Issues**
- Verify: `.netrc` file configured
- Check: Network access to Artifactory
- Clear: SPM cache and retry

---

## Performance Tips

- **Incremental Builds:** Don't clean unless necessary
- **Parallel Tests:** Enable in test configuration
- **Build Cache:** Use DerivedData for faster rebuilds
- **Simulator:** Debug on simulator is faster than device
- **SwiftLint Cache:** Use `--cache-path` for faster linting

---

## Continuous Integration

### CI Workflow
```yaml
steps:
  - name: Build
    run: build sdk showcase
  
  - name: Test
    run: run tests
    
  - name: Quality
    run: run quality checks
    
  - name: Archive
    run: build sdk showcase (Release)
```

---

## Contributing

### Adding New Workflows
1. Create workflow markdown in this directory
2. Follow existing workflow structure
3. Update this README with new workflow entry
4. Test workflow thoroughly
5. Commit to mobile-cline-bank repository

### Modifying Workflows
1. Edit workflow in `mobile-cline-bank/Workflows/projects/ios/sdk-showcase/`
2. Test changes
3. Run `update cline bank` to sync to `.clinerules/`
4. Commit changes

---

## Getting Started

1. **Setup Environment:**
   ```bash
   # Configure SPM registry
   swift package-registry set --global https://thalescpliam.jfrog.io/artifactory/api/swift/swift-public --netrc
   ```

2. **Build Project:**
   ```bash
   build sdk showcase
   ```

3. **Run Tests:**
   ```bash
   run tests
   ```

4. **Check Quality:**
   ```bash
   run quality checks
   ```

---

## Support

For issues or questions:
- **Internal:** Contact iOS Development Team
- **Cline Bank:** Review mobile-cline-bank documentation
- **OMI SDK:** Check SDK documentation

---

## Related Documentation

- [Mobile Cline Bank](../../../README.md) - Complete workflow system
- [iOS Workflows](../README.md) - All iOS project workflows
- [OMI SDK Docs](https://thalesdocs.com/oip/omi-sdk/ios-sdk/) - Official SDK documentation

---

**Maintained By:** iOS Development Team  
**Created:** 2026-01-30  
**Last Updated:** 2026-01-30  
**Version:** 1.0.0
