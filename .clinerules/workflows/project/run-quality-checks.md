# Run SDK Showcase Quality Checks

**Version:** 1.0.0  
**Platform:** iOS  
**Project:** sdk-showcase  
**Last Updated:** 2026-01-30

---

## Overview

Run code quality checks for the **OMI SDK Showcase App** including SwiftLint analysis, code formatting verification, and static analysis.

## Trigger Commands

- `run quality checks`
- `check code quality`
- `run swiftlint`
- `quality check`

---

## Prerequisites

- **SwiftLint** installed (`brew install swiftlint`)
- **Xcode 15.4+** installed
- **Project built** at least once

---

## Workflow Steps

### Step 1: Verify SwiftLint Installation

Check if SwiftLint is installed and get version.

```bash
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint not installed. Installing..."
    brew install swiftlint
else
    echo "✅ SwiftLint installed: $(swiftlint version)"
fi
```

### Step 2: Run SwiftLint Analysis

Execute SwiftLint on the entire project.

```bash
cd "SDK Showcase"
swiftlint lint --reporter emoji
```

### Step 3: Generate HTML Report (Optional)

Create an HTML report for detailed analysis.

```bash
swiftlint lint --reporter html > swiftlint-report.html
echo "📊 Report generated: swiftlint-report.html"
open swiftlint-report.html
```

### Step 4: Check for Auto-Fixable Issues

Show issues that can be automatically fixed.

```bash
swiftlint lint --strict --reporter emoji
```

### Step 5: Run Xcode Static Analyzer (Optional)

Execute Xcode's built-in static analyzer.

```bash
xcodebuild analyze \
  -project "SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

---

## SwiftLint Configuration

### Default Rules Applied

The project should have a `.swiftlint.yml` configuration file. If not, create one:

```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - closure_spacing
included:
  - SDK Showcase
excluded:
  - Pods
  - SDK Showcase/Supporting Files/Swinject.xcframework
  - Configuration
line_length:
  warning: 140
  error: 200
type_body_length:
  warning: 300
  error: 500
file_length:
  warning: 500
  error: 1000
```

---

## Auto-Fix Issues

### Fix Automatically

Apply automatic fixes for certain violations.

```bash
cd "SDK Showcase"
swiftlint lint --fix
echo "✅ Auto-fixable issues corrected"
```

### Preview Fixes

See what would be fixed without applying changes.

```bash
swiftlint lint --fix --format --dry-run
```

---

## Quality Metrics

### Violation Severity Levels

- **Error** 🔴 - Must fix before merge
- **Warning** 🟡 - Should fix soon
- **Info** ⚪️ - Consider fixing

### Acceptance Criteria

✅ **0 errors** - No errors allowed  
✅ **<10 warnings** - Minimize warnings  
✅ **Clean static analysis** - No analyzer issues  

---

## Common SwiftLint Rules

### Critical Rules (Errors)

| Rule | Description | Example |
|------|-------------|---------|
| `force_cast` | No force casting | Use `as?` not `as!` |
| `force_unwrapping` | No force unwrapping | Use `if let` not `!` |
| `implicit_getter` | Omit `get` for read-only | `var x: Int { value }` |
| `trailing_semicolon` | No semicolons | Remove `;` |

### Style Rules (Warnings)

| Rule | Description | Example |
|------|-------------|---------|
| `line_length` | Max line length | <140 chars |
| `type_name` | Type naming | UpperCamelCase |
| `identifier_name` | Variable naming | lowerCamelCase |
| `vertical_whitespace` | Max blank lines | ≤2 lines |

---

## Integration with Xcode

### Run SwiftLint on Build

Add a Run Script build phase in Xcode:

```bash
if which swiftlint > /dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

This shows warnings/errors in Xcode during build.

---

## Troubleshooting

### SwiftLint Not Found

**Issue:** `swiftlint: command not found`

**Solution:**
```bash
# Install via Homebrew
brew install swiftlint

# Or via Mint
mint install realm/SwiftLint

# Verify installation
which swiftlint
swiftlint version
```

### Too Many Warnings

**Issue:** Overwhelming number of warnings

**Solution:**
```bash
# Focus on errors only first
swiftlint lint --strict

# Or disable specific rules temporarily
# Edit .swiftlint.yml to disable rules
```

### Configuration Not Found

**Issue:** SwiftLint not using project config

**Solution:**
```bash
# Verify .swiftlint.yml exists in project root
ls -la .swiftlint.yml

# Specify config explicitly
swiftlint lint --config .swiftlint.yml
```

### Slow Analysis

**Issue:** SwiftLint takes too long

**Solution:**
```bash
# Analyze only changed files
git diff --name-only | grep ".swift$" | xargs swiftlint lint --path

# Or use cache
swiftlint lint --cache-path .swiftlint.cache
```

---

## Additional Quality Checks

### Check for TODOs/FIXMEs

```bash
# Find all TODO and FIXME comments
grep -r "TODO\|FIXME" "SDK Showcase" --include="*.swift" || echo "✅ No TODOs or FIXMEs found"
```

### Check File Headers

```bash
# Verify copyright headers
find "SDK Showcase" -name "*.swift" -exec head -n 5 {} \; | grep -c "Copyright" || echo "⚠️ Some files missing headers"
```

### Check for Debug Code

```bash
# Look for print statements (should use Logger)
grep -r "print(" "SDK Showcase" --include="*.swift" || echo "✅ No print statements found"
```

---

## Continuous Integration

### CI Quality Check Command

```bash
#!/bin/bash
set -e

echo "🔍 Running quality checks..."

# Run SwiftLint
echo "📝 Running SwiftLint..."
swiftlint lint --strict --reporter emoji

# Run static analyzer
echo "🔬 Running static analyzer..."
xcodebuild analyze \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -quiet

echo "✅ All quality checks passed!"
```

---

## Best Practices

✅ **Run before commit** - Catch issues early  
✅ **Fix errors immediately** - Don't accumulate technical debt  
✅ **Review warnings weekly** - Plan cleanup sprints  
✅ **Update config as needed** - Adapt rules to project  
✅ **Auto-fix when safe** - Use `--fix` for formatting  
✅ **Document exceptions** - Use `// swiftlint:disable` with comments  

---

## Output Files

- **swiftlint-report.html** - HTML quality report
- **swiftlint-report.json** - JSON quality data
- **analyze-results/** - Static analyzer findings

---

## Next Steps

After quality checks:
1. **Fix errors:** Address all SwiftLint errors
2. **Review warnings:** Plan fixes for warnings
3. **Run tests:** `run tests`
4. **Commit:** `git commit`

---

## Related Workflows

- [build-app](./build-app.md) - Build the application
- [run-tests](./run-tests.md) - Execute test suites
- [clean-build](./clean-build.md) - Clean and rebuild

---

**Maintained By:** iOS Development Team  
**Contact:** [Team Channel]
