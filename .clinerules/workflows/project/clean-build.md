# Clean Build SDK Showcase

**Version:** 1.0.0  
**Platform:** iOS  
**Project:** sdk-showcase  
**Last Updated:** 2026-01-30

---

## Overview

Clean all build artifacts, derived data, and caches for the **OMI SDK Showcase App**, then perform a fresh rebuild. This resolves most build issues and ensures a pristine build environment.

## Trigger Commands

- `clean build`
- `clean and rebuild`
- `rebuild sdk showcase`
- `fresh build`

---

## Prerequisites

- **Xcode 15.4+** installed
- **Project accessible**

---

## Workflow Steps

### Step 1: Clean Build Folder

Clean Xcode build folder for the project.

```bash
xcodebuild clean \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -configuration Debug

echo "✅ Build folder cleaned"
```

### Step 2: Remove Derived Data

Delete all derived data for SDK Showcase.

```bash
# Find and remove derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/SDK_Showcase-*

# Or remove all derived data (more aggressive)
# rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "✅ Derived data removed"
```

### Step 3: Clean SPM Cache

Clear Swift Package Manager cache and re-resolve dependencies.

```bash
# Clear SPM cache
rm -rf ~/Library/Caches/org.swift.swiftpm

# Clear project SPM cache
rm -rf "SDK Showcase/.build"

# Re-resolve packages
xcodebuild -resolvePackageDependencies \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase"

echo "✅ SPM dependencies re-resolved"
```

### Step 4: Clean Module Cache

Remove Xcode module cache.

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache

echo "✅ Module cache cleared"
```

### Step 5: Reset Simulators (Optional)

Reset all iOS simulators to clean state.

```bash
# Shutdown all simulators
xcrun simctl shutdown all

# Erase all simulators (WARNING: destroys all simulator data)
# xcrun simctl erase all

echo "✅ Simulators reset"
```

### Step 6: Rebuild Project

Perform fresh build after cleaning.

```bash
xcodebuild build \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -derivedDataPath ./build

echo "✅ Project rebuilt successfully!"
```

---

## Clean Levels

### Level 1: Basic Clean (Fast)

Quick clean of build folder only.

```bash
xcodebuild clean -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"
```

**Use when:** Minor build issues, quick refresh needed

### Level 2: Deep Clean (Recommended)

Clean build folder + derived data.

```bash
xcodebuild clean -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"
rm -rf ~/Library/Developer/Xcode/DerivedData/SDK_Showcase-*
```

**Use when:** Build errors, indexing issues, autocomplete problems

### Level 3: Nuclear Clean (Aggressive)

Complete clean including SPM cache, modules, and simulators.

```bash
# Clean everything
xcodebuild clean -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache*
xcrun simctl shutdown all
xcrun simctl erase all

# Re-resolve dependencies
xcodebuild -resolvePackageDependencies -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"
```

**Use when:** Persistent build failures, dependency conflicts, corrupt caches

---

## What Gets Cleaned

| Component | Location | Size Impact | Rebuild Time |
|-----------|----------|-------------|--------------|
| Build folder | `<project>/build/` | ~100-500 MB | Fast (incremental) |
| Derived data | `~/Library/Developer/Xcode/DerivedData/` | ~1-5 GB | Medium |
| SPM cache | `~/Library/Caches/org.swift.swiftpm` | ~500 MB | Slow (re-download) |
| Module cache | `.../DerivedData/ModuleCache*` | ~100-200 MB | Medium |
| Simulators | Simulator data | Varies | N/A |

---

## Troubleshooting

### Clean Fails

**Issue:** Clean command fails

**Solution:**
```bash
# Force quit Xcode first
killall Xcode

# Wait a moment
sleep 2

# Retry clean
xcodebuild clean -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"
```

### Permission Denied

**Issue:** Cannot delete derived data

**Solution:**
```bash
# Check ownership
ls -la ~/Library/Developer/Xcode/DerivedData/

# Fix permissions if needed
sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/SDK_Showcase-*

# Retry delete
rm -rf ~/Library/Developer/Xcode/DerivedData/SDK_Showcase-*
```

### SPM Dependencies Won't Resolve

**Issue:** Package resolution fails after clean

**Solution:**
```bash
# Check network connectivity
ping thalescpliam.jfrog.io

# Verify authentication
cat ~/.netrc | grep thalescpliam.jfrog.io

# Re-configure SPM registry
swift package-registry set --global https://thalescpliam.jfrog.io/artifactory/api/swift/swift-public --netrc

# Clear SPM cache completely
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/.swiftpm

# Retry resolution
xcodebuild -resolvePackageDependencies -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"
```

### Rebuild Takes Too Long

**Issue:** Rebuild after clean is very slow

**Solution:**
- **Don't use nuclear clean** unless absolutely necessary
- **Use Level 2** (deep clean) as default
- **Keep SPM cache** if dependencies haven't changed
- **Clean specific targets** instead of entire project if possible

---

## When to Clean Build

### Recommended Scenarios

✅ **Build errors** that disappear after restart  
✅ **Indexing issues** in Xcode  
✅ **Autocomplete not working** properly  
✅ **Strange linker errors**  
✅ **After changing** dependencies or project settings  
✅ **Before important** builds (release, demo)  
✅ **Switching branches** with different dependencies  

### Not Recommended

❌ **After every code change** - waste of time  
❌ **As first debugging step** - try simpler solutions first  
❌ **Daily routine** - only when needed  

---

## Automated Clean Scripts

### Quick Clean Script

```bash
#!/bin/bash
# quick-clean.sh

echo "🧹 Quick clean starting..."

xcodebuild clean \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase"

rm -rf ~/Library/Developer/Xcode/DerivedData/SDK_Showcase-*

echo "✅ Quick clean completed!"
```

### Deep Clean Script

```bash
#!/bin/bash
# deep-clean.sh

echo "🧹 Deep clean starting..."

# Clean build
xcodebuild clean -project "SDK Showcase/SDK Showcase.xcodeproj" -scheme "SDK Showcase"

# Remove derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/SDK_Showcase-*

# Clean SPM
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf "SDK Showcase/.build"

# Clean modules
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache*

# Re-resolve
xcodebuild -resolvePackageDependencies \
  -project "SDK Showcase/SDK Showcase.xcodeproj" \
  -scheme "SDK Showcase"

echo "✅ Deep clean completed!"
echo "📦 Dependencies re-resolved"
```

---

## Performance Impact

| Clean Level | Time | Disk Space Freed | Rebuild Time |
|-------------|------|------------------|--------------|
| Basic | 5-10s | ~100-500 MB | 1-2 min |
| Deep | 10-30s | ~1-5 GB | 2-5 min |
| Nuclear | 30-60s | ~5-10 GB | 5-15 min |

---

## Best Practices

✅ **Clean before release builds** - Ensure pristine state  
✅ **Clean after dependency changes** - Avoid conflicts  
✅ **Don't clean unnecessarily** - Wastes time  
✅ **Use appropriate level** - Match severity to issue  
✅ **Close Xcode first** - Prevent file locks  
✅ **Commit before cleaning** - Safety net  

---

## Next Steps

After clean build:
1. **Verify build:** Check for any errors
2. **Run tests:** `run tests`
3. **Quality check:** `run quality checks`
4. **Resume work:** Continue development

---

## Related Workflows

- [build-app](./build-app.md) - Build the application
- [run-tests](./run-tests.md) - Execute test suites
- [run-quality-checks](./run-quality-checks.md) - Code quality analysis

---

**Maintained By:** iOS Development Team  
**Contact:** [Team Channel]
