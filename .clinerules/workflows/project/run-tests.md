# Run SDK Showcase Tests

**Version:** 1.0.0  
**Platform:** iOS  
**Project:** sdk-showcase  
**Last Updated:** 2026-01-30

---

## Overview

Execute unit tests and UI tests for the **OMI SDK Showcase App**. The test suite includes:
- **SDK ShowcaseTests:** Unit tests for interactors and models
- **Test Coverage:** CategoriesInteractor, SDKInteractor, and Model tests

## Trigger Commands

- `run tests`
- `run sdk showcase tests`
- `test sdk showcase`
- `test app`

---

## Prerequisites

- **Xcode 15.4+** installed
- **iOS Simulator** available
- **Dependencies resolved** (SPM packages)
- **Test target configured:** SDK ShowcaseTests

---

## Workflow Steps

### Step 1: List Available Test Targets

Display available test targets.

```bash
xcodebuild -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -list -json | jq '.project.targets[] | select(. | contains("Test"))'
```

### Step 2: Run Unit Tests

Execute the SDK ShowcaseTests unit test suite.

```bash
xcodebuild test \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:SDK\ ShowcaseTests \
  -resultBundlePath ./test-results
```

### Step 3: Display Test Results

Show test execution summary.

```bash
# Extract test results
xcrun xcresulttool get --path ./test-results.xcresult \
  --format json > test-summary.json

# Display summary
echo "✅ Test execution completed!"
cat test-summary.json | jq '.actions[].actionResult.testsRef' 
```

### Step 4: Check Test Coverage (Optional)

Generate and display code coverage report.

```bash
# Enable coverage in build settings first
xcodebuild test \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -enableCodeCoverage YES \
  -resultBundlePath ./coverage-results

# View coverage
xcrun xccov view --report \
  ./coverage-results.xcresult \
  --json > coverage.json

cat coverage.json | jq '.targets[] | {name: .name, coverage: .lineCoverage}'
```

---

## Test Targets

### SDK ShowcaseTests
- **Type:** Unit Tests
- **Bundle ID:** `com.onewelcome.omi.SDK-ShowcaseTests`
- **Test Files:**
  - `CategoriesInteractorTest.swift`
  - `ModelTests.swift`
  - `SDKInteractorTest.swift`
  - `Mocks/CategoriesInteractorMock.swift`

---

## Test Execution Options

### Run All Tests
```bash
xcodebuild test \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

### Run Specific Test Class
```bash
xcodebuild test \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:SDK\ ShowcaseTests/CategoriesInteractorTest
```

### Run Specific Test Method
```bash
xcodebuild test \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:SDK\ ShowcaseTests/CategoriesInteractorTest/testMethodName
```

### Skip Specific Tests
```bash
xcodebuild test \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -skip-testing:SDK\ ShowcaseTests/SlowTest
```

---

## Simulator Options

### Different iOS Versions
```bash
# iOS 17.0
-destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'

# iOS 17.6 (deployment target)
-destination 'platform=iOS Simulator,name=iPhone 15,OS=17.6'

# Latest available
-destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

### Different Device Types
```bash
# iPhone SE
-destination 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=latest'

# iPad
-destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch),OS=latest'

# Multiple devices (parallel)
-destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
-destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch),OS=latest'
```

---

## Test Configuration

### Enable Code Coverage
Add to test command:
```bash
-enableCodeCoverage YES
```

### Parallel Testing
Add to test command:
```bash
-parallel-testing-enabled YES
-parallel-testing-worker-count 4
```

### Test Timeout
Add to test command:
```bash
-maximum-test-execution-time-allowance 300  # 5 minutes
```

---

## Troubleshooting

### Simulator Not Available

**Issue:** Simulator not found

**Solution:**
```bash
# List available simulators
xcrun simctl list devices available

# Boot simulator before testing
xcrun simctl boot "iPhone 15"

# Or let xcodebuild boot automatically
```

### Test Target Not Found

**Issue:** Test target cannot be found

**Solution:**
```bash
# Verify test target exists
xcodebuild -project "SDK Showcase/SDK Showcase.xcodeproj" -list

# Clean build folder
xcodebuild clean -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"

# Rebuild and test
xcodebuild build-for-testing -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"
```

### Test Crashes or Hangs

**Issue:** Tests crash or hang

**Solution:**
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/SDK_Showcase-*

# Retry tests
```

### Missing Dependencies

**Issue:** Tests fail due to missing dependencies

**Solution:**
```bash
# Resolve SPM dependencies
xcodebuild -resolvePackageDependencies \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase"

# Retry tests
```

---

## Coverage Analysis

### Generate HTML Coverage Report
```bash
# Run tests with coverage
xcodebuild test \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -enableCodeCoverage YES \
  -resultBundlePath ./coverage.xcresult

# Convert to HTML (requires xcov or similar tool)
# Or view in Xcode: open coverage.xcresult
```

### View Coverage Summary
```bash
xcrun xccov view --report coverage.xcresult --json | \
  jq '.targets[] | select(.name == "SDK Showcase.app") | {
    name: .name,
    lineCoverage: .lineCoverage,
    files: [.files[] | {name: .name, coverage: .lineCoverage}]
  }'
```

---

## Test Best Practices

✅ **Run tests before committing** - Ensure code quality  
✅ **Check coverage** - Maintain >70% code coverage  
✅ **Test on multiple devices** - Verify compatibility  
✅ **Keep tests fast** - Unit tests should be quick  
✅ **Mock external dependencies** - Use test doubles  
✅ **Write meaningful assertions** - Verify behavior, not implementation  

---

## Continuous Integration

### CI Command
```bash
# Full CI test suite
xcodebuild test \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -enableCodeCoverage YES \
  -resultBundlePath ./ci-results \
  -parallel-testing-enabled YES \
  | xcpretty --color --report html
```

---

## Output Files

- **test-results.xcresult** - Test execution results
- **coverage.xcresult** - Code coverage data  
- **test-summary.json** - JSON test summary
- **coverage.json** - JSON coverage report

---

## Next Steps

After successful tests:
1. **Review coverage:** Check coverage.json
2. **Fix failures:** Address any failing tests
3. **Quality check:** `run quality checks`
4. **Commit changes:** `git commit`

---

## Related Workflows

- [build-app](./build-app.md) - Build the application
- [run-quality-checks](./run-quality-checks.md) - Code quality analysis
- [clean-build](./clean-build.md) - Clean and rebuild

---

**Maintained By:** iOS Development Team  
**Contact:** [Team Channel]
