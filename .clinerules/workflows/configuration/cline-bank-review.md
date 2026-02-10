# Cline Bank Review Configuration Workflow

**Version:** 1.0.0  
**Last Updated:** 2026-01-26  
**Status:** Active

---

## Overview

This workflow displays your current Cline Bank configuration in a detailed, easy-to-read format. Use it to understand what rules and workflows are installed, when they were last updated, and to access quick actions.

## Workflow Purpose

Review your Cline configuration by:
1. Loading your configuration file
2. Displaying comprehensive details about installed rules and workflows
3. Showing file counts and categories
4. Providing quick access to update and modify workflows
5. Validating configuration integrity

## Trigger Commands

- `review cline bank config`
- `review cline bank`
- `show cline config`
- `cline bank status`

## Prerequisites

- Existing `.clinerules/cline-bank-config.json` configuration file

## Workflow Steps

### Step 1: Load and Validate Configuration

**Action:** Read configuration and check for issues

**Process:**
1. Load `.clinerules/cline-bank-config.json`
2. Validate JSON structure
3. Check for missing or corrupted data
4. Verify files exist
5. Calculate statistics

**If configuration is valid:**
```
✓ Configuration loaded successfully
✓ All required fields present
✓ 30 files verified
```

**If issues found:**
```
⚠️  Configuration Issues Detected:
  • 2 files missing from .clinerules/
  • Last update was 45 days ago (consider updating)
  
Details will be shown in the review below.
```

---

### Step 2: Display Configuration Overview

**Action:** Show high-level configuration summary

**Output:**
```
╔════════════════════════════════════════════════════════╗
║        Cline Bank Configuration Review                 ║
╚════════════════════════════════════════════════════════╝

Configuration Version: 1.0.0
Setup Date: January 20, 2026 at 10:30 AM
Last Updated: January 26, 2026 at 6:45 PM
Days Since Update: 0 days

Platform: Android
Project: mppsdk (MobilePassPlus SDK)
Submodule Path: mobile-cline-bank

Overall Health: ✓ Excellent
  ✓ All files present
  ✓ Recently updated
  ✓ No conflicts detected
```

---

### Step 3: Display Rules Details

**Action:** Show installed rules by category

**Output:**
```
═══════════════════════════════════════════════════════
RULES CONFIGURATION
═══════════════════════════════════════════════════════

Common Rules (5 files, ~35KB)
─────────────────────────────
  ✓ common-rules.md                      15 KB
  ✓ code-quality-rules.md                 8 KB
  ✓ code-quality-condensed-rules.md       4 KB
  ✓ security-condensed-rules.md           6 KB
  ✓ ide-configuration-rules.md            2 KB

Platform Rules: Android (4 files, ~28KB)
────────────────────────────────────────
  ✓ android-library-rules.md              7 KB
  ✓ java-kotlin-rules.md                 12 KB
  ✓ jetpack-compose-api-rules.md          5 KB
  ✓ jetpack-compose-component-rules.md    4 KB

Security Rules (1 file, ~8KB)
─────────────────────────────
  ✓ general-security-rules.md             8 KB

Native Rules
────────────
  (none installed)

OWASP Security Rules
────────────────────
  (not installed - using condensed version)

───────────────────────────────────────────────────────
Total Rules: 10 files, ~71 KB
```

---

### Step 4: Display Workflows Details

**Action:** Show installed workflows by category

**Output:**
```
═══════════════════════════════════════════════════════
WORKFLOWS CONFIGURATION
═══════════════════════════════════════════════════════

Git Workflows (3 files)
───────────────────────
  ✓ git-commit.md         - Stage and commit changes
  ✓ git-branch.md         - Create and switch branches  
  ✓ git-sync.md           - Sync with remote repository

Jira Workflows (6 files)
────────────────────────
  ✓ jira-ticket-creation.md        - Create Jira tickets
  ✓ jira-ticket-search.md          - Search for tickets
  ✓ jira-ticket-codebase.md        - Map tickets to code
  ✓ generate-jira-content.md       - Generate story content
  ✓ jira-to-code.md                - Sprint to code workflow
  ✓ check-sprint-status.md         - Check sprint progress

Merge Request Workflows (3 files)
─────────────────────────────────
  ✓ mr-review.md                   - AI-assisted MR review
  ✓ mr-review-request.md           - Request MR reviews
  ✓ developer-self-review.md       - Self-review checklist

Project Workflows: mppsdk (8 files)
───────────────────────────────────
  ✓ build-sdk.md                   - Build SDK modules
  ✓ test-sdk.md                    - Run SDK tests
  ✓ check-quality.md               - Quality analysis
  ✓ clean-build.md                 - Clean and rebuild
  ✓ generate-docs.md               - Generate API docs
  ✓ install-library.md             - Install to Maven
  ✓ release-sdk.md                 - Release SDK
  ✓ README.md                      - Project overview

Confluence Workflows
────────────────────
  (not installed)

Documentation Workflows
───────────────────────
  (not installed)

Team Workflows
──────────────
  (not installed)

Configuration Workflows
───────────────────────
  (not installed)

───────────────────────────────────────────────────────
Total Workflows: 20 files
```

---

### Step 5: Display Update History

**Action:** Show recent configuration changes

**Output:**
```
═══════════════════════════════════════════════════════
UPDATE HISTORY
═══════════════════════════════════════════════════════

Most Recent Update: January 26, 2026 at 6:45 PM
  • 3 files updated
  • 1 new file added
  • Backup: .clinerules/.backups/2026-01-26_184500/

Previous Update: January 22, 2026 at 2:30 PM
  • 2 files updated
  • Backup: .clinerules/.backups/2026-01-22_143000/

Initial Setup: January 20, 2026 at 10:30 AM
  • 30 files installed

───────────────────────────────────────────────────────
Total Updates: 2 (since initial setup)
Available Backups: 2
```

---

### Step 6: File Integrity Check

**Action:** Verify all configured files exist

**Output:**
```
═══════════════════════════════════════════════════════
FILE INTEGRITY CHECK
═══════════════════════════════════════════════════════

Checking 30 configured files...
[████████████████████] 100%

Results:
  ✓ Present: 30 files
  ✗ Missing: 0 files
  ⚠️  Modified locally: 0 files

All configured files are present and unmodified.
```

**If files are missing:**
```
⚠️  Missing Files Detected:

The following configured files are missing:
  ✗ rules/common/yaml-json-rules.md
  ✗ workflows/jira/ticket-grooming.md

Possible causes:
  • Files were manually deleted
  • Configuration out of sync
  
Recommendations:
  • Run "update cline bank" to restore files
  • Run "modify cline bank" to remove from config
```

**If files were modified:**
```
⚠️  Locally Modified Files:

The following files have been modified:
  ⚠️  rules/android/java-kotlin-rules.md
  ⚠️  workflows/git/git-commit.md

These files differ from the mobile-cline-bank source.

Recommendations:
  • Run "update cline bank" to restore originals
  • Keep modifications (they'll be overwritten on update)
  • Document custom changes separately
```

---

### Step 7: Recommendations

**Action:** Provide personalized recommendations

**Output:**
```
═══════════════════════════════════════════════════════
RECOMMENDATIONS
═══════════════════════════════════════════════════════

Based on your configuration:

💡 Suggested Additions:
  → Documentation workflows (produce-diagrams.md)
     Reason: Useful for project understanding
     
  → Team workflows (onboarding-checklist.md)
     Reason: Streamline team onboarding
     
  → Additional Jira workflows (ticket-grooming.md, 
     sprint-retro-generator.md)
     Reason: You use Jira workflows, these complement them

📊 Token Usage Analysis:
  Current: ~71 KB rules + ~40 KB workflows = ~111 KB
  Available: ~200 KB typical context window
  Status: ✓ Well within limits
  
  You can safely add more rules/workflows if needed.

🔄 Update Status:
  Last update: Today
  Status: ✓ Up to date
  
  Next check recommended: February 26, 2026

🎯 Configuration Quality:
  • Good balance of rules and workflows
  • Using condensed rules (good for tokens)
  • Missing some useful workflow categories
  • Overall: B+ (Very Good)
```

---

### Step 8: Quick Actions Menu

**Action:** Offer common actions

**Output:**
```
═══════════════════════════════════════════════════════
QUICK ACTIONS
═══════════════════════════════════════════════════════

What would you like to do?

1. Update configuration         - Sync with latest from bank
2. Modify configuration          - Add or remove items
3. Export configuration          - Save summary to file
4. Check for updates             - See what's changed
5. Restore from backup           - Revert to previous state
6. Validate files                - Deep integrity check
7. Show statistics               - Detailed usage stats
8. Exit                          - Close review

Enter choice (1-8):
```

---

## Advanced Features

### Export Configuration Summary

**Trigger:** Select "Export configuration" from quick actions

**Process:**
1. Generate comprehensive report
2. Save to file
3. Include all details in markdown format

**Output:**
```
Exporting configuration summary...

Report saved to: .clinerules/cline-bank-summary.md

This file contains:
  • Complete configuration details
  • File lists with descriptions
  • Update history
  • Recommendations
  • Quick reference guide

You can:
  • Share with team members
  • Add to project documentation
  • Use as reference for other projects
```

**Sample export content:**
```markdown
# Cline Bank Configuration Summary

Generated: January 26, 2026

## Overview
- Platform: Android
- Project: mppsdk
- Setup: January 20, 2026
- Last Update: January 26, 2026

## Installed Rules (10 files)

### Common Rules
- common-rules.md - Core development patterns
- code-quality-rules.md - Quality standards
...

## Installed Workflows (20 files)
...
```

---

### Detailed Statistics

**Trigger:** Select "Show statistics" from quick actions

**Output:**
```
═══════════════════════════════════════════════════════
DETAILED STATISTICS
═══════════════════════════════════════════════════════

File Distribution
─────────────────
Rules:     10 files (33%)
Workflows: 20 files (67%)
Total:     30 files

Category Breakdown
──────────────────
Common Rules:        5 files (17%)
Platform Rules:      4 files (13%)
Security Rules:      1 file  (3%)
Git Workflows:       3 files (10%)
Jira Workflows:      6 files (20%)
MR Workflows:        3 files (10%)
Project Workflows:   8 files (27%)

Size Analysis
─────────────
Total Size:          ~111 KB
Average File Size:   ~3.7 KB
Largest File:        java-kotlin-rules.md (12 KB)
Smallest File:       ide-configuration-rules.md (2 KB)

Update Frequency
────────────────
Updates Since Setup: 2
Days Since Setup:    6
Days Since Update:   0
Average Update Freq: Every 3 days

Usage Potential
───────────────
Rule Coverage:       Medium (core + platform)
Workflow Coverage:   Good (git, jira, mr, project)
Missing Categories:  4 (confluence, docs, team, config)
Expansion Potential: High (can add ~90KB more)

Configuration Score
───────────────────
Completeness:        7/10 (Good)
Balance:             8/10 (Very Good)
Currency:            10/10 (Excellent)
Health:              10/10 (Excellent)

Overall Grade:       A- (Excellent)
```

---

### Deep File Validation

**Trigger:** Select "Validate files" from quick actions

**Process:**
1. Check each file exists
2. Verify file size is reasonable
3. Check file is readable
4. Validate markdown syntax
5. Check for common issues

**Output:**
```
Running Deep File Validation...
[████████████████████] 100%

Results by Category:

Rules Files:
  ✓ common-rules.md              OK (15 KB, valid markdown)
  ✓ code-quality-rules.md        OK (8 KB, valid markdown)
  ✓ java-kotlin-rules.md         OK (12 KB, valid markdown)
  ✓ android-library-rules.md     OK (7 KB, valid markdown)
  ... (6 more)

Workflow Files:
  ✓ git-commit.md                OK (5 KB, valid markdown)
  ✓ git-branch.md                OK (4 KB, valid markdown)
  ⚠️  jira-to-code.md             Warning: Large file (15 KB)
  ✓ mr-review.md                 OK (8 KB, valid markdown)
  ... (16 more)

Issues Found: 1
  ⚠️  jira-to-code.md is larger than typical (15 KB)
     This is normal for complex workflows, but may impact token usage.

Overall: ✓ All files valid and accessible
```

---

### Compare Configurations

**Trigger:** "compare cline bank config with [project/path]"

**Purpose:** Compare your configuration with another project or a previous backup

**Output:**
```
Configuration Comparison
════════════════════════

Your Config vs. Other Project Config

Differences:

Rules:
  Your Config Only:
    + code-quality-condensed-rules.md
    + security-condensed-rules.md
    
  Other Config Only:
    + yaml-json-rules.md
    + Full OWASP rules (14 files)

Workflows:
  Your Config Only:
    + mr-review-request.md
    + developer-self-review.md
    
  Other Config Only:
    + confluence-search.md
    + produce-diagrams.md
    + onboarding-checklist.md

Summary:
  Your config: 30 files
  Other config: 42 files
  In common: 20 files
  Differences: 22 files
```

---

## Error Handling

### Configuration File Missing

**Error:** Configuration file not found

**Output:**
```
❌ Configuration Not Found

Cannot find .clinerules/cline-bank-config.json

This usually means:
  • Cline Bank hasn't been set up yet
  • Configuration file was deleted
  • Wrong directory

Would you like to:
1. Run initial setup
2. Search for configuration in parent directories
3. Exit
```

---

### Configuration File Corrupted

**Error:** Cannot parse configuration JSON

**Output:**
```
❌ Configuration File Corrupted

The configuration file exists but cannot be parsed.

Error: Unexpected token in JSON at position 145

Backup location (if available):
  .clinerules/.backups/2026-01-26_184500/cline-bank-config.json

Would you like to:
1. Restore from latest backup
2. Show configuration file content
3. Run fresh setup (will lose current config)
4. Cancel
```

---

### Files Missing

**Error:** Configured files don't exist

**Output:**
```
⚠️  Missing Files Detected

5 configured files are missing from .clinerules/:
  ✗ rules/common/yaml-json-rules.md
  ✗ workflows/jira/ticket-grooming.md
  ✗ workflows/jira/sprint-retro-generator.md
  ✗ workflows/documentation/produce-diagrams.md
  ✗ workflows/team/onboarding-checklist.md

This might indicate:
  • Files were manually deleted
  • Configuration is out of sync
  • Restore operation failed

Recommendations:
1. Run "update cline bank" to restore missing files
2. Run "modify cline bank" to remove missing items from config
3. Check if files were moved manually
```

---

## Use Cases

### Use Case 1: Regular Health Check

```
Developer: review cline bank config

[Shows full configuration review]
[Everything looks good]

Developer: Great, I'm up to date!
```

### Use Case 2: Before Major Changes

```
Developer: review cline bank config
[Exports configuration summary]

Developer: modify cline bank
[Makes changes]

[If issues occur, can restore from export/backup]
```

### Use Case 3: Onboarding New Team Member

```
Lead: review cline bank config
[Selects "Export configuration"]

Lead: [Shares summary with new team member]

New Dev: [Runs same setup based on summary]
```

### Use Case 4: Troubleshooting

```
Developer: My workflows aren't working

Support: review cline bank config
[Checks file integrity]
[Finds 3 missing files]

Support: Run "update cline bank" to restore them
```

### Use Case 5: Optimization

```
Developer: review cline bank config
[Shows statistics]
[Sees token usage is high]

Developer: modify cline bank
[Switches to condensed rules]
[Token usage reduced by 40%]
```

---

## Best Practices

1. **Regular Reviews:** Check configuration monthly
2. **Before Updates:** Review before running updates
3. **After Changes:** Verify after modifying configuration
4. **Export Summaries:** Keep exports for team reference
5. **Monitor Health:** Watch for warnings and recommendations
6. **Track Updates:** Note when you last updated
7. **Share Knowledge:** Export and share configurations with team

---

## Tips

1. **Quick Health Check:** Just run the command to see status at a glance
2. **Export for Documentation:** Use exports in project documentation
3. **Compare Setups:** Compare configurations across projects for consistency
4. **Monitor Token Usage:** Keep an eye on total size if context window is limited
5. **Follow Recommendations:** The workflow suggests useful additions
6. **Check Integrity:** Run validation if workflows behave unexpectedly

---

## Related Workflows

- **Initial Setup:** `setup cline bank` - First-time configuration
- **Update:** `update cline bank` - Sync with latest changes
- **Modify:** `modify cline bank config` - Change selections

---

## Version History

**v1.0.0** (2026-01-26)
- Initial version
- Configuration overview display
- File integrity checking
- Statistics and analysis
- Export functionality
- Recommendations engine
- Quick actions menu

---

**Workflow Author:** Mobile Development Team  
**Last Review:** 2026-01-26  
**Next Review:** 2026-04-26
