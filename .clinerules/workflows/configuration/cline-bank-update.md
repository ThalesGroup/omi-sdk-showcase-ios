# Cline Bank Update Workflow

**Version:** 1.1.0  
**Last Updated:** 2026-01-27  
**Status:** Active  
**Compatible With:** Setup v2.0.0

---

## Overview

This workflow syncs your project's rules and workflows with the latest changes from the mobile-cline-bank repository. It checks for updates and allows you to selectively or automatically update changed files.

**Supports:**
- Standard configurations with existing platforms/projects
- Configurations with generated workflows and custom platforms

## Workflow Purpose

Keep your Cline configuration up-to-date by:
1. Reading your existing configuration
2. Checking for changes in the mobile-cline-bank submodule
3. Identifying which files have been updated
4. Selectively or automatically updating files
5. Preserving your configuration

## Trigger Commands

- `update cline bank`
- `sync cline bank`
- `refresh cline rules`
- `cline bank update`

## Prerequisites

- Existing `.clinerules/cline-bank-config.json` configuration file
- Mobile-cline-bank submodule present and accessible
- Git installed (for checking file changes)

## Workflow Steps

### Step 1: Validate Configuration

**Action:** Check that configuration file exists and is valid

**Process:**
1. Look for `.clinerules/cline-bank-config.json`
2. Parse and validate JSON structure
3. Verify submodule path is correct

**If configuration missing:**
```
⚠️  No configuration file found.

It looks like you haven't set up Cline Bank yet.

Would you like to run the initial setup?
- Yes, run setup
- No, cancel
```

**If found and valid:**
```
✓ Configuration found
  Platform: Android
  Project: mppsdk
  Last update: 2026-01-20
```

---

### Step 2: Update Submodule

**Action:** Ensure mobile-cline-bank submodule is up-to-date

**Process:**
1. Navigate to submodule directory
2. Run `git fetch origin`
3. Check if local is behind remote
4. Optionally pull latest changes

**Question:** "Update mobile-cline-bank to latest version?"

**Options:**
- Yes, update submodule
- No, use current version
- Show what's changed

**If updates available:**
```
📦 Submodule Updates Available:
   Current: abc1234 (2026-01-20)
   Latest:  def5678 (2026-01-26)
   
   Recent changes:
   - Updated Android Jetpack Compose rules
   - Added new Jira workflow for ticket grooming
   - Fixed typos in security rules
   
Update to latest?
```

---

### Step 3: Check for File Changes

**Action:** Compare source files with installed files

**Process:**
1. Read fileMapping from configuration
2. For each mapped file:
   - Get modification time or git hash of source
   - Get modification time of destination
   - Compare to detect changes
3. Categorize files:
   - Changed (needs update)
   - New (newly available)
   - Unchanged (up-to-date)
   - Missing source (removed from bank)
   - Missing destination (needs reinstall)

**Output:**
```
Checking for updates...
[████████████████████] 100%

📋 Update Analysis:
   ✓ Changed files: 3
   ✓ New files available: 1
   ✓ Up-to-date: 28
   ✓ Missing from destination: 0
   
Total files checked: 32
```

---

### Step 4: Show Changes

**Action:** Display detailed list of changes

**Output:**
```
📝 Files with Updates:

Changed Files (3):
  1. rules/android/java-kotlin-rules.md
     Last updated: 2 days ago
     Changes: Added coroutine best practices
     
  2. workflows/jira/jira-ticket-creation.md
     Last updated: 1 day ago
     Changes: Improved epic linking support
     
  3. rules/common/security-condensed-rules.md
     Last updated: 3 days ago
     Changes: Updated encryption guidelines

New Files Available (1):
  4. workflows/jira/ticket-grooming.md
     Added: 1 day ago
     Description: Automate backlog grooming preparation
     Category: Jira workflows (already selected)

Up-to-date Files: 28 files
```

---

### Step 5: Select Update Strategy

**Action:** Ask user how to proceed with updates

**Question:** "How would you like to update?"

**Options:**
1. **Update all changed files** (Recommended)
   - Updates 3 changed files
   - Adds 1 new file
   - Preserves 28 unchanged files
   
2. **Select files to update**
   - Choose which files to update individually
   
3. **Show detailed diff first**
   - View changes before deciding
   
4. **Cancel**
   - Don't update anything

**For Option 2 (Select files):**
```
Select files to update:
[x] 1. rules/android/java-kotlin-rules.md
[x] 2. workflows/jira/jira-ticket-creation.md
[ ] 3. rules/common/security-condensed-rules.md
[x] 4. workflows/jira/ticket-grooming.md (new)

Use arrow keys to navigate, space to select/deselect, enter to confirm
```

**For Option 3 (Show diff):**
```
Showing changes for: rules/android/java-kotlin-rules.md

+++ Added Section: Coroutine Best Practices
    
    ## Coroutine Best Practices
    
    1. Always use structured concurrency
    2. Prefer viewModelScope over GlobalScope
    3. Handle cancellation properly
    ...

Proceed with update? (y/n/skip/diff next)
```

---

### Step 6: Backup Current Files

**Action:** Create backup of files being updated

**Process:**
1. Create `.clinerules/.backups/` directory
2. Create timestamped backup folder
3. Copy files being updated to backup

**Output:**
```
Creating backup...
✓ Backup created: .clinerules/.backups/2026-01-26_184500/

Files backed up:
  - rules/android/java-kotlin-rules.md
  - workflows/jira/jira-ticket-creation.md
  - rules/common/security-condensed-rules.md
```

---

### Step 7: Update Files

**Action:** Copy updated files from mobile-cline-bank to .clinerules

**Process:**
1. For each selected file:
   - Copy from source to destination
   - Preserve permissions
   - Update file mapping in config
2. Show progress
3. Verify all copies succeeded

**Output:**
```
Updating files...
[████████████████████] 100%

✓ Updated rules/android/java-kotlin-rules.md
✓ Updated workflows/jira/jira-ticket-creation.md
✓ Updated rules/common/security-condensed-rules.md
✓ Added workflows/jira/ticket-grooming.md

4 files updated successfully
```

---

### Step 8: Update Configuration

**Action:** Update configuration file with new timestamps and mappings

**Process:**
1. Update `lastUpdate` timestamp
2. Add new files to fileMapping
3. Update file counts
4. Save configuration

**Updated config:**
```json
{
  "version": "1.0.0",
  "setupDate": "2026-01-20T10:30:00Z",
  "lastUpdate": "2026-01-26T18:45:00Z",
  "platform": "android",
  "project": "mppsdk",
  "updateHistory": [
    {
      "date": "2026-01-26T18:45:00Z",
      "filesUpdated": 4,
      "backupPath": ".clinerules/.backups/2026-01-26_184500/"
    }
  ],
  ...
}
```

**Note:** For configurations with generated workflows or custom platforms, additional fields like `platformStatus`, `projectStatus`, and `requiresRepoUpdate` are preserved during updates.

---

### Step 9: Summary

**Action:** Display update summary and next steps

**Output:**
```
✅ Update Complete!

Summary:
────────
✓ 3 files updated
✓ 1 new file added
✓ 28 files unchanged
✓ Backup saved to: .clinerules/.backups/2026-01-26_184500/

Updated Files:
  ✓ rules/android/java-kotlin-rules.md
  ✓ workflows/jira/jira-ticket-creation.md
  ✓ rules/common/security-condensed-rules.md

New Files:
  ✓ workflows/jira/ticket-grooming.md

Configuration updated: .clinerules/cline-bank-config.json

📚 What's New:
  • Enhanced coroutine guidelines in Java/Kotlin rules
  • Improved Jira epic linking in ticket creation workflow
  • Updated encryption best practices in security rules
  • New ticket grooming workflow for backlog preparation

💡 Next Steps:
  1. Review updated rules/workflows if needed
  2. Try new ticket grooming workflow: "prepare grooming session"
  3. If issues occur, restore from backup: .clinerules/.backups/2026-01-26_184500/

🔄 Last update: January 26, 2026 at 6:45 PM
```

---

## Advanced Options

### Selective Category Update

**Trigger during update:** "Only update workflows" or "Only update rules"

**Process:**
1. Filter changes by category (rules vs workflows)
2. Show only relevant changes
3. Update only selected category

**Example:**
```
User: update cline bank workflows only

Checking workflow updates...

📝 Workflow Updates Available (2):
  1. workflows/jira/jira-ticket-creation.md (changed)
  2. workflows/jira/ticket-grooming.md (new)

Rules updates (3 files) will be skipped.

Proceed with workflow updates?
```

---

### Force Update All

**Trigger:** "force update cline bank"

**Process:**
1. Skip change detection
2. Copy all configured files from source
3. Overwrite all existing files
4. Useful if local files were modified

**Warning:**
```
⚠️  Force Update Warning

This will overwrite ALL files in .clinerules/ with fresh copies from mobile-cline-bank.

Any local modifications will be lost (backup will be created).

Files to overwrite: 32

Are you sure you want to proceed?
- Yes, force update all
- No, cancel
```

---

### Check Only (Dry Run)

**Trigger:** "check for cline bank updates"

**Process:**
1. Run all checks
2. Show what would be updated
3. Don't actually update anything

**Output:**
```
Checking for updates... (dry run)

📋 Updates Available:
   3 changed files
   1 new file

No files were updated. Run "update cline bank" to apply updates.
```

---

## Rollback Support

### Restore from Backup

**Trigger:** "restore cline bank backup"

**Process:**
1. List available backups
2. Ask user which backup to restore
3. Copy files from backup to .clinerules
4. Update configuration

**Example:**
```
Available Backups:
──────────────────
1. 2026-01-26 6:45 PM (4 files) - Most recent
2. 2026-01-20 2:30 PM (8 files)
3. 2026-01-15 10:15 AM (3 files)

Which backup would you like to restore?
```

---

## Error Handling

### Submodule Not Updated

**Error:** Submodule is behind but git fetch fails

**Action:**
```
⚠️  Cannot update submodule

Git fetch failed. This might be due to:
- No network connection
- Authentication issues
- Git not installed

Would you like to:
1. Continue with current submodule version
2. Cancel update
3. Show git error details
```

---

### File Copy Failed

**Error:** Cannot copy file to destination

**Action:**
```
❌ Failed to copy file

Could not update: rules/android/java-kotlin-rules.md

Possible reasons:
- Permission denied
- Disk full
- File in use

Backup preserved at: .clinerules/.backups/2026-01-26_184500/

Would you like to:
1. Retry
2. Skip this file
3. Cancel update
```

---

### Configuration Update Failed

**Error:** Cannot save updated configuration

**Action:**
```
⚠️  Configuration update failed

Files were updated successfully, but configuration file could not be saved.

This means next update won't know which files were updated.

Recommendation: Manually verify .clinerules/cline-bank-config.json

Continue anyway?
```

---

## Best Practices

1. **Update regularly:** Run monthly or when submodule is updated
2. **Review changes:** Use "Show detailed diff" for important updates
3. **Keep backups:** Automatic backups are kept for 30 days
4. **Test after update:** Verify workflows still function correctly
5. **Update submodule first:** Always pull latest submodule before updating
6. **Read change notes:** Check what's new in updated files

---

## Automation Ideas

### Scheduled Updates

Add to your project's CI/CD or cron:

```bash
# Weekly check for updates
0 9 * * 1 cd /path/to/project && cline "check for cline bank updates"
```

### Git Hook

Add to `.git/hooks/post-merge`:

```bash
#!/bin/bash
# Check for cline bank updates after git pull
if git diff HEAD@{1} HEAD --name-only | grep -q "mobile-cline-bank"; then
  echo "Mobile-cline-bank submodule changed. Consider running: cline 'update cline bank'"
fi
```

---

## Related Workflows

- **Initial Setup:** `setup cline bank` - First-time configuration
- **Modify Configuration:** `modify cline bank config` - Change selections
- **Review Configuration:** `review cline bank config` - View current setup

---

## Special Handling for Generated Workflows

### Auto-Generated Workflows

If your project has auto-generated workflows (indicated in configuration):

**Configuration indicator:**
```json
{
  "projectWorkflowsGenerated": true,
  "requiresRepoUpdate": true
}
```

**Update behavior:**
- Generated workflows are treated as regular workflows
- Updates available if templates in mobile-cline-bank change
- Customized workflows: Updates show as conflicts (you can skip or review)

**Recommendation:** Review generated workflow updates carefully to preserve your customizations.

---

### New Platform Rules

If you created a new platform and later added rules:

**Before adding rules:**
```json
{
  "platformStatus": "new",
  "pendingActions": ["Add platform-specific rules to Rules/myplatform/"]
}
```

**After rules added:**
1. Update mobile-cline-bank repository with new rules
2. Run `update cline bank` to pull in your new rules
3. Configuration will show new rules available for selection
4. Choose to add them to your existing setup

---

## Version History

**v1.1.0** (2026-01-27)
- Added support for dynamic setup configurations (v2.0.0)
- Handles generated workflows properly
- Supports new platforms added dynamically
- Preserves extended configuration fields

**v1.0.0** (2026-01-26)
- Initial version
- Automatic change detection
- Selective updates
- Backup support
- Force update option
- Rollback capability

---

**Workflow Author:** Mobile Development Team  
**Last Review:** 2026-01-27  
**Next Review:** 2026-04-27
