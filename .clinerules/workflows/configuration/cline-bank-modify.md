# Cline Bank Modify Configuration Workflow

**Version:** 1.1.0  
**Last Updated:** 2026-01-27  
**Status:** Active  
**Compatible With:** Setup v2.0.0

---

## Overview

This workflow allows you to modify your existing Cline Bank configuration by adding or removing rules and workflows, or changing your project selection.

## Workflow Purpose

Customize your Cline configuration by:
1. Reading your existing configuration
2. Allowing you to add new rules or workflows
3. Allowing you to remove existing rules or workflows
4. Switching to a different project
5. Updating files and configuration accordingly

## Trigger Commands

- `modify cline bank config`
- `modify cline bank`
- `change cline config`
- `cline bank modify`

## Prerequisites

- Existing `.clinerules/cline-bank-config.json` configuration file
- Mobile-cline-bank submodule present and accessible

## Workflow Steps

### Step 1: Load Configuration

**Action:** Read and display current configuration

**Process:**
1. Load `.clinerules/cline-bank-config.json`
2. Count installed rules and workflows
3. Display summary

**Output:**
```
Current Cline Bank Configuration
════════════════════════════════

Platform: Android
Project: mppsdk (MobilePassPlus SDK)

Setup Date: January 20, 2026
Last Update: January 26, 2026

Installed Files:
  • Rules: 12 files
  • Workflows: 18 files
  • Total: 30 files

Configuration loaded successfully.
```

---

### Step 2: Select Modification Type

**Action:** Ask what the user wants to modify

**Question:** "What would you like to modify?"

**Options:**
1. **Add rules**
   - Add new rule categories or files
   
2. **Remove rules**
   - Remove existing rule categories or files
   
3. **Add workflows**
   - Add new workflow categories or files
   
4. **Remove workflows**
   - Remove existing workflow categories or files
   
5. **Change project**
   - Switch to a different project (changes project-specific workflows)
   
6. **Change platform**
   - Switch platform (requires full reconfiguration)
   
7. **Cancel**
   - Exit without changes

---

### Step 3A: Add Rules

**Triggered when:** User selects "Add rules"

**Process:**
1. Analyze current rules configuration
2. Show available rules NOT currently installed
3. Group by category
4. Allow multi-select

**Display:**
```
Available Rules to Add
═══════════════════════

Common Rules:
  [ ] project-setup-guide-rules.md
  [ ] yaml-json-rules.md

Android Rules:
  [ ] android-application-rules.md (you have library rules)
  [ ] condensed/java-kotlin-condensed-rules.md
  [ ] condensed/jetpack-compose-condensed-rules.md

Security Rules:
  [ ] Full OWASP rules (14 files)
  [ ] Platform SDK security rules

Native Rules:
  [ ] C standards rules
  [ ] C++ legacy standards rules

Select rules to add (use space to select, enter to confirm):
```

**After selection:**
```
You selected:
  ✓ yaml-json-rules.md
  ✓ condensed/java-kotlin-condensed-rules.md
  ✓ Full OWASP rules (14 files)

This will add 16 files.

Proceed? (y/n)
```

**On confirmation:**
1. Copy selected files from mobile-cline-bank to .clinerules
2. Update configuration
3. Show summary

```
Adding rules...
[████████████████████] 100%

✓ Copied Rules/common/yaml-json-rules.md
✓ Copied Rules/android/condensed/java-kotlin-condensed-rules.md
✓ Copied Rules/common/owasp/_00-master-owasp-policy.md
✓ Copied Rules/common/owasp/01-input-validation.md
... (14 OWASP files)

16 files added successfully.
Configuration updated.
```

---

### Step 3B: Remove Rules

**Triggered when:** User selects "Remove rules"

**Process:**
1. Show currently installed rules
2. Group by category
3. Allow multi-select for removal
4. Confirm before deletion

**Display:**
```
Installed Rules
═══════════════

Common Rules (5 files):
  [x] common-rules.md
  [x] code-quality-rules.md
  [x] code-quality-condensed-rules.md
  [x] security-condensed-rules.md
  [x] ide-configuration-rules.md

Android Rules (4 files):
  [x] android-library-rules.md
  [x] java-kotlin-rules.md
  [x] jetpack-compose-api-rules.md
  [x] jetpack-compose-component-rules.md

Security Rules (1 file):
  [x] general-security-rules.md

Select rules to remove (use space to select, enter to confirm):
```

**After selection:**
```
⚠️  Warning: Remove Rules

You selected to remove:
  ✗ code-quality-condensed-rules.md
  ✗ security-condensed-rules.md

Files will be deleted from .clinerules/

Are you sure? (y/n)
```

**On confirmation:**
1. Delete selected files from .clinerules
2. Update configuration
3. Show summary

```
Removing rules...

✓ Removed rules/common/code-quality-condensed-rules.md
✓ Removed rules/common/security-condensed-rules.md

2 files removed successfully.
Configuration updated.
```

---

### Step 3C: Add Workflows

**Triggered when:** User selects "Add workflows"

**Process:**
1. Analyze current workflow configuration
2. Show available workflow categories NOT currently installed
3. Show individual workflow files that can be added
4. Allow multi-select

**Display:**
```
Available Workflows to Add
═══════════════════════════

Workflow Categories:
  [ ] Confluence workflows (1 file)
  [ ] Documentation workflows (3 files)
  [ ] Team workflows (1 file)
  [ ] Configuration workflows (2 files)

Individual Workflows (from installed categories):
  Jira (currently have 6 of 10):
    [ ] ticket-grooming.md
    [ ] sprint-retro-generator.md
    [ ] predict-rollovers.md
    [ ] check-story-description.md

Select workflows to add:
```

**After selection:**
```
You selected:
  ✓ Documentation workflows (3 files)
  ✓ Jira: ticket-grooming.md
  ✓ Jira: sprint-retro-generator.md

This will add 5 files.

Proceed? (y/n)
```

**On confirmation:**
```
Adding workflows...
[████████████████████] 100%

✓ Copied Workflows/documentation/produce-diagrams.md
✓ Copied Workflows/documentation/project-doc-generation.md
✓ Copied Workflows/documentation/project-doc-generation-README.md
✓ Copied Workflows/jira/ticket-grooming.md
✓ Copied Workflows/jira/sprint-retro-generator.md

5 files added successfully.
Configuration updated.
```

---

### Step 3D: Remove Workflows

**Triggered when:** User selects "Remove workflows"

**Process:**
1. Show currently installed workflows
2. Group by category
3. Allow multi-select for removal
4. Warn about removing entire categories
5. Confirm before deletion

**Display:**
```
Installed Workflows
═══════════════════

Git Workflows (3 files):
  [x] git-commit.md
  [x] git-branch.md
  [x] git-sync.md

Jira Workflows (6 files):
  [x] jira-ticket-creation.md
  [x] jira-ticket-search.md
  [x] jira-ticket-codebase.md
  [x] generate-jira-content.md
  [x] jira-to-code.md
  [x] check-sprint-status.md

Merge Request Workflows (3 files):
  [x] mr-review.md
  [x] mr-review-request.md
  [x] developer-self-review.md

Project Workflows (8 files):
  [x] mppsdk/build-sdk.md
  [x] mppsdk/test-sdk.md
  ... (6 more)

Select workflows to remove:
```

**Warning for category removal:**
```
⚠️  Warning: Remove Entire Category

You selected all files in these categories:
  ✗ Merge Request Workflows (3 files)

This will remove the entire category.

Also removing:
  ✗ Jira: generate-jira-content.md

Total: 4 files will be deleted.

Are you sure? (y/n)
```

---

### Step 3E: Change Project

**Triggered when:** User selects "Change project"

**Process:**
1. Show current project
2. List available projects for current platform
3. Confirm change
4. Remove old project workflows
5. Add new project workflows

**Display:**
```
Change Project
══════════════

Current project: mppsdk (MobilePassPlus SDK)
Current platform: Android

Available Android Projects:
  1. fkm - Fido Key Manager
  2. mpp - MobilePassPlus Application
  3. mppsdk - MobilePassPlus SDK (current)

Select new project (or 'c' to cancel):
```

**After selection:**
```
Project Change Confirmation
═══════════════════════════

From: mppsdk (MobilePassPlus SDK)
To:   mpp (MobilePassPlus Application)

This will:
  ✗ Remove 8 mppsdk workflow files
  ✓ Add 5 mpp workflow files

Your global workflows and rules will be preserved.

Proceed? (y/n)
```

**On confirmation:**
```
Changing project...

Removing old project workflows...
✓ Removed workflows/project/mppsdk/ (8 files)

Adding new project workflows...
✓ Copied Workflows/projects/android/mpp/build-android-app.md
✓ Copied Workflows/projects/android/mpp/run-android-tests.md
✓ Copied Workflows/projects/android/mpp/run-code-quality-checks.md
✓ Copied Workflows/projects/android/mpp/run-security-scan.md
✓ Copied Workflows/projects/android/mpp/create-release-package.md

Project changed successfully.
Configuration updated.
```

---

### Step 3F: Change Platform

**Triggered when:** User selects "Change platform"

**Warning:**
```
⚠️  Warning: Platform Change

Changing platform requires reconfiguring most of your setup.

Current: Android
Available: iOS

Platform-specific items that will be affected:
  • Android rules (will be replaced with iOS rules)
  • Project workflows (will need to select new project)

Items that will be preserved:
  • Common rules
  • Global workflows (Git, Jira, Confluence, etc.)

Recommendation: Run "setup cline bank" instead for full reconfiguration.

Do you want to:
  1. Continue with platform change
  2. Run full setup instead
  3. Cancel
```

**If user continues:**
1. Remove platform-specific rules
2. Remove project workflows
3. Add new platform rules (interactive selection)
4. Select new project (interactive selection)
5. Add new project workflows

---

### Step 4: Verify Changes

**Action:** Show summary of modifications

**Output:**
```
Modification Summary
═══════════════════

Changes made:
  ✓ Added 5 workflow files
  ✓ Removed 2 rule files
  ✓ Configuration updated

New totals:
  • Rules: 10 files (was 12)
  • Workflows: 23 files (was 18)
  • Total: 33 files (was 30)

Files added:
  + workflows/documentation/produce-diagrams.md
  + workflows/documentation/project-doc-generation.md
  + workflows/documentation/project-doc-generation-README.md
  + workflows/jira/ticket-grooming.md
  + workflows/jira/sprint-retro-generator.md

Files removed:
  - rules/common/code-quality-condensed-rules.md
  - rules/common/security-condensed-rules.md

Configuration saved: .clinerules/cline-bank-config.json
```

---

### Step 5: Post-Modification Actions

**Action:** Offer additional actions

**Options:**
```
What would you like to do next?

1. Make more modifications
2. Update all files to latest version
3. Review full configuration
4. Done
```

---

## Batch Modifications

### Modify Multiple Items at Once

**Trigger:** "modify cline bank - add workflows and remove rules"

**Process:**
1. Ask for all modifications upfront
2. Show combined summary
3. Apply all changes together
4. Single configuration update

**Example:**
```
Batch Modification Mode
═══════════════════════

Select all modifications to make:

Add Rules:
  [ ] yaml-json-rules.md
  [ ] Full OWASP rules

Remove Rules:
  [x] code-quality-condensed-rules.md

Add Workflows:
  [x] Documentation workflows
  [x] Team workflows

Remove Workflows:
  (none)

Confirm these changes? (y/n)
```

---

## Smart Recommendations

### Suggest Related Items

When adding/removing, suggest related items:

```
You're adding: Documentation workflows

Related items you might want:
  → Confluence workflows (for storing generated docs)
  → Jira workflows (for documenting tickets)

Add these too? (y/n/select)
```

---

### Detect Conflicts

Warn about potential issues:

```
⚠️  Potential Issue

You're removing: java-kotlin-rules.md

But you still have:
  • jetpack-compose-api-rules.md (depends on Kotlin rules)
  • Project workflows that build Kotlin code

Recommendation: Keep java-kotlin-rules.md

Proceed anyway? (y/n/keep it)
```

---

## Error Handling

### Configuration File Missing

**Error:** No configuration file found

**Action:**
```
❌ No Configuration Found

Cannot modify configuration because .clinerules/cline-bank-config.json doesn't exist.

Would you like to:
1. Run initial setup
2. Cancel
```

---

### File Deletion Failed

**Error:** Cannot delete file

**Action:**
```
❌ Failed to delete file

Could not remove: rules/common/security-condensed-rules.md

Possible reasons:
- File is in use
- Permission denied
- File doesn't exist

Would you like to:
1. Retry
2. Skip this file (will update config anyway)
3. Cancel all changes
```

---

### Source File Not Found

**Error:** File to add doesn't exist in mobile-cline-bank

**Action:**
```
⚠️  Source File Missing

Cannot add: workflows/jira/ticket-grooming.md
File not found in mobile-cline-bank.

This might mean:
- Submodule is out of date
- File was moved or renamed
- Incorrect path in selection

Would you like to:
1. Update submodule and retry
2. Skip this file
3. Cancel
```

---

## Best Practices

1. **Start small:** Add a few items at a time, test them
2. **Review before removing:** Make sure you won't need removed items
3. **Keep backups:** Changes can be reverted using update workflow backups
4. **Update after modifying:** Run `update cline bank` to sync modified files
5. **Document custom items:** If you add custom rules, note them separately
6. **Use recommendations:** Follow suggested related items
7. **Test workflows:** Try new workflows after adding them

---

## Common Modification Scenarios

### Scenario 1: Add Missing Workflows

```
User: I need ticket grooming and retro generation workflows

Cline: [Runs modify workflow]
      [Shows Jira workflows]
      [User selects both]
      [Copies files]
      ✓ Added 2 workflows
```

### Scenario 2: Switch from Condensed to Full Rules

```
User: modify cline bank - replace condensed rules with full versions

Cline: [Removes condensed rules]
       [Adds full versions]
       ✓ Removed 3 condensed files
       ✓ Added 3 full files
```

### Scenario 3: Change Project

```
User: I'm moving to a different project, need different build workflows

Cline: [Runs change project]
       [Shows project options]
       [Switches from mppsdk to mpp]
       ✓ Project changed
       ✓ 8 old workflows removed
       ✓ 5 new workflows added
```

### Scenario 4: Add Full Security Suite

```
User: add complete OWASP security rules

Cline: [Shows security options]
       [User selects full OWASP]
       ✓ Adding 14 OWASP files
       ⚠️  This will add ~100KB to your rules
       [User confirms]
       ✓ All OWASP rules added
```

---

## Tips

1. **Token Considerations:** Adding many rules increases context size
2. **Selective Addition:** Only add rules/workflows you'll actually use
3. **Category vs Individual:** Adding a category is faster than individual files
4. **Review After:** Use `review cline bank config` to verify changes
5. **Undo via Update:** Restore previous state from update backups

---

## Related Workflows

- **Initial Setup:** `setup cline bank` - First-time configuration
- **Update:** `update cline bank` - Sync with latest changes
- **Review:** `review cline bank config` - View current setup

---

## Version History

**v1.1.0** (2026-01-27)
- Added support for setup v2.0.0 configurations
- Handles generated workflows and custom platforms
- Preserves extended configuration fields

**v1.0.0** (2026-01-26)
- Initial version
- Add/remove rules and workflows
- Change project
- Change platform
- Batch modifications
- Smart recommendations

---

**Workflow Author:** Mobile Development Team  
**Last Review:** 2026-01-27  
**Next Review:** 2026-04-27
