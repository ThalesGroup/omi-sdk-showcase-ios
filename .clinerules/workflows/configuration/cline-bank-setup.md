# Cline Bank Setup Workflow

**Version:** 2.0.0  
**Last Updated:** 2026-01-27  
**Status:** Active

---

## Overview

This workflow helps you configure your project with rules and workflows from the mobile-cline-bank repository. It automatically discovers available platforms and projects, and creates new ones if needed.

**Smart Behavior:**
- ✅ **For existing platforms/projects:** Simple, fast setup - just select and copy files
- ✅ **For new platforms/projects:** Extended workflow with creation and generation capabilities

## Key Features

✅ **Automatic Discovery** - Finds all available platforms and projects  
✅ **Create New Platforms** - Add Windows, macOS, or custom platforms when needed  
✅ **Create New Projects** - Add projects with auto-generated workflows when needed  
✅ **Workflow Auto-Generation** - Creates project-specific workflows for new projects only  
✅ **Self-Updating** - Updates documentation when structure changes  
✅ **Repository Management** - Updates mobile-cline-bank with new content when needed

---

## Workflow Purpose

Automate setup with dynamic capabilities:
1. Discover or create development platform
2. Discover or create project
3. Select rules to include
4. Select workflow categories
5. Auto-generate missing workflows
6. Copy all to `.clinerules` directory
7. Update mobile-cline-bank repository
8. Self-update this workflow

---

## Trigger Commands

- `setup cline bank`
- `configure cline rules`
- `initialize cline bank`
- `cline bank setup`

---

## Step 1: Platform Selection (Dynamic)

**Action:** Discover available platforms and ask user to select or create new

**Process:**
1. Scan `Rules/` directory for platform folders
2. List discovered platforms: `android/`, `ios/`, `windows/`, `native/`, etc.
3. Present options including "Add new platform"

**Question:** "Which platform are you developing for?"

**Dynamic Options:**
```
Current Platforms:
1. Android
2. iOS  
3. Windows (NEW!)
4. Native (C/C++)
---
5. Add New Platform (e.g., macOS, Linux, etc.)
```

**If user selects "Add New Platform":**

**Sub-Question:** "Enter the new platform name (lowercase, single word):"

**Examples:** `macos`, `linux`, `embedded`, `web`

**Actions when new platform chosen:**
1. Create directory structure:
   ```
   Rules/<platform>/
   Rules/<platform>/condensed/
   Workflows/projects/<platform>/
   ```

2. Create `Rules/<platform>/README.md` with template
3. Prompt user: "This is a new platform. You'll need to add platform-specific rules later."
4. Note in setup log: "⚠️ Remember to populate `Rules/<platform>/` with coding rules"
5. Continue setup with available common rules

---

## Step 2: Project Selection

**Action:** Discover available projects for selected platform or create new

**Process:**
1. Scan `Workflows/projects/<platform>/` for project folders
2. List discovered projects with descriptions from README.md files
3. If projects exist, include "Add new project" option

**Question:** "Which project are you working on?"

**Example for Android (existing projects):**
```
Current Android Projects:
1. fkm - Fido Key Manager
2. mpp - MobilePassPlus
3. mppsdk - MobilePassPlus SDK
---
4. Add New Project
```

**Example for Windows (new platform, no projects yet):**
```
Windows Platform (New)
No projects available yet.

Would you like to create a new project? (y/n)
```

**If user selects "Add New Project":**

**Important Note:**
```
⚠️ Project-Specific Workflow Generation Requires Memory Bank

Project-specific workflows cannot be created during initial setup because they 
require an initialized memory bank to be accurate and complete.

The memory bank helps understand your project structure, dependencies, build 
processes, and conventions - essential for generating useful workflows.

Process:
1. Complete this setup (rules and global workflows only)
2. Initialize the memory bank by working with Cline on your project
3. Use 'create project workflows' command to generate project-specific workflows

This ensures your project workflows are tailored to your actual codebase.
```

**Question:** "Would you like to note this project for later workflow creation?"

**If yes:**
- Store project name for reference
- Continue setup without project workflows
- Add reminder to post-setup instructions

**If no:**
- Continue without project association
- User can still use global workflows

---

## Step 3: Rules Selection

**Action:** Ask which rule categories to include

**Question:** "Which rules would you like to add? (Select multiple)"

**Common Rules (applicable to all platforms):**
- [ ] Common rules (project setup, IDE configuration, patterns)
- [ ] Code quality rules (quality standards, best practices)
- [ ] Security rules (general security, OWASP guidelines)
- [ ] YAML/JSON rules (configuration file standards)
- [ ] Python rules (Python development, scripting)
- [ ] TypeScript/JavaScript rules (web development, Node.js)
- [ ] Cypress rules (E2E testing for web applications)

**Platform-Specific Rules (dynamically discovered from `Rules/<platform>/`):**

**For Android:**
- [ ] Android application rules
- [ ] Android library rules
- [ ] Java/Kotlin rules
- [ ] Jetpack Compose rules (API and components)
- [ ] Condensed rules (compact versions)

**For iOS:**
- [ ] iOS application rules
- [ ] Swift/iOS rules
- [ ] SwiftUI rules (API and components)
- [ ] Objective-C rules
- [ ] Condensed rules (compact versions)

**For Windows:**
- [ ] .NET Core / .NET 5+ rules
- [ ] .NET Framework rules
- [ ] Windows desktop application rules
- [ ] Python rules (if doing scripting)
- [ ] Condensed rules (compact versions)

**For Native (C/C++):**
- [ ] C standards rules
- [ ] C++ legacy standards rules
- [ ] Modern C++ rules (if available)

**For New Platforms:**
- Display: "⚠️ This is a new platform. Only common rules are available."
- Show only common rules
- Note: "Add platform-specific rules to `Rules/<platform>/` and run setup again"

**Advanced Security (optional):**
- [ ] Full OWASP rules (14 detailed security modules)
- [ ] Platform SDK security rules

**Recommendations:**
- **For Mobile (Android/iOS):**
  - Minimum: Common rules + Platform-specific rules
  - Recommended: Add security rules + YAML/JSON rules
  - Optional: Python (for build scripts), TypeScript/JavaScript (for tooling)
  
- **For Web/Full-Stack:**
  - Minimum: Common rules + TypeScript/JavaScript rules
  - Recommended: Add Cypress rules + Security rules
  - Optional: Python (for backend/scripts)
  
- **For Windows Desktop:**
  - Minimum: Common rules + .NET rules
  - Recommended: Add security rules + YAML/JSON rules
  - Optional: Python (for automation scripts), TypeScript (for web components)
  
- **Token-conscious:** Use condensed versions when available (60-77% savings)

---

## Step 4: Workflow Categories Selection

**Action:** Ask which workflow categories to include

**Question:** "Which workflow categories would you like to add? (Select multiple)"

**Global Workflow Categories:**
- [ ] Git workflows (commit, branch, sync)
- [ ] Merge request workflows (review, review request)
- [ ] Jira workflows (ticket creation, search, sprint management, grooming)
- [ ] Confluence workflows (search, documentation)
- [ ] Documentation workflows (diagrams, project docs)
- [ ] Team workflows (onboarding)
- [ ] Configuration workflows (workflow setup, standards)

**Project-Specific Workflows:**
- [ ] Project workflows (build, test, release for selected project)

**Status Display:**
- Show if project has workflows: "✅ 8 workflows available"
- Show if no workflows available: "⚠️ No project workflows - use 'create project workflows' after memory bank initialization"

**Recommendations:**
- **Minimum:** Git workflows + Project workflows (if available)
- **Recommended:** Add Jira and Merge request workflows
- **Full setup:** Include all categories for complete automation

---

## Step 5: Review Selection

**Action:** Display summary and confirm

**Summary Display:**
```
Configuration Summary
===================

Platform: Android
Project: mppsdk (MobilePassPlus SDK)
Project Status: ✅ Existing (8 workflows available)

Rules Selected:
✓ Common rules
✓ Code quality rules
✓ Security rules (condensed)
✓ Android library rules
✓ Java/Kotlin rules
✓ Jetpack Compose rules

Workflows Selected:
✓ Git workflows
✓ Merge request workflows
✓ Jira workflows
✓ Project workflows (mppsdk - 8 files)

Files to Copy: 45
Destination: .clinerules/
```

**For New Platform:**
```
Platform: macos (NEW - created during setup)
Project Status: ⚠️ Will use common rules only

⚠️ TODO After Setup:
1. Add macOS-specific coding rules to mobile-cline-bank/Rules/macos/
2. Run 'update cline bank' to include new rules
```

**For New Project:**
```
Project: authsdk (NEW - noted for later workflow creation)
Project Type: SDK/Library

⚠️ Project workflows NOT created during setup:
   Reason: Requires initialized memory bank for accuracy

📋 Next Steps After Setup:
1. Work with Cline to initialize memory bank
2. Use command: 'create project workflows'
3. Workflows will be generated based on actual project structure
```

**Question:** "Proceed with this configuration?"

**Options:**
- Yes, proceed
- No, let me change selections
- Cancel

---

## Step 6: File Copying

**Action:** Copy selected files to project

**Process:**

### 6A. Create Directory Structure

**Create `.clinerules/` structure:**
```
.clinerules/
├── rules/
│   ├── common/
│   ├── <platform>/
│   └── native/ (if needed)
├── workflows/
│   ├── git/
│   ├── jira/
│   ├── confluence/
│   ├── merge-requests/
│   ├── documentation/
│   ├── team/
│   ├── configuration/
│   └── project/
└── MCP/
```

### 6C. Copy Rules Files

**Copy selected rules:**
- Copy common rules from `Rules/common/` to `.clinerules/rules/common/`
- Copy platform rules from `Rules/<platform>/` to `.clinerules/rules/<platform>/`
- Copy security rules if selected
- Copy OWASP rules if full OWASP selected

### 6D. Copy Workflow Files

**Copy selected workflows:**
- Copy global workflows from `Workflows/<category>/` to `.clinerules/workflows/<category>/`
- Copy or use generated project workflows to `.clinerules/workflows/project/`

### 6E. Copy MCP Configuration

- Copy `MCP/cline_mcp_settings.template.json` to `.clinerules/MCP/`

**Progress Display:**
```
Copying files...
[████████████████████] 100%

✓ Copied 15 common rules
✓ Copied 8 Android rules
✓ Copied 12 Git workflows
✓ Copied 9 Jira workflows
✓ Copied 6 Project workflows (generated)
✓ Copied MCP configuration

Total: 50 files copied/generated successfully
```

---

## Step 7: Save Configuration

**Action:** Create configuration file

**File:** `.clinerules/cline-bank-config.json`

**Enhanced Content (with new fields):**
```json
{
  "version": "2.0.0",
  "setupDate": "2026-01-27T18:45:00Z",
  "lastUpdate": "2026-01-27T18:45:00Z",
  "platform": "android",
  "platformStatus": "existing",
  "project": "mppsdk",
  "projectFullName": "MobilePassPlus SDK",
  "projectStatus": "existing",
  "projectType": "sdk",
  "rules": {
    "common": [
      "common-rules.md",
      "code-quality-rules.md",
      "security-condensed-rules.md"
    ],
    "platform": [
      "android-library-rules.md",
      "java-kotlin-rules.md"
    ],
    "security": [
      "general-security-rules.md"
    ]
  },
  "workflows": {
    "global": [
      "git",
      "merge-requests",
      "jira"
    ],
    "project": "mppsdk",
    "projectWorkflowsGenerated": false
  },
  "fileMapping": {
    "rules/common/common-rules.md": "Rules/common/common-rules.md",
    "workflows/project/build-sdk.md": "Workflows/projects/android/mppsdk/build-sdk.md"
  },
  "submodulePath": "mobile-cline-bank",
  "requiresRepoUpdate": false,
  "pendingActions": []
}
```

**For new platform/project:**
```json
{
  "platformStatus": "new",
  "projectStatus": "new",
  "projectWorkflowsGenerated": true,
  "requiresRepoUpdate": true,
  "pendingActions": [
    "Add platform-specific rules to Rules/windows/",
    "Review generated workflows in mobile-cline-bank",
    "Commit and push mobile-cline-bank changes",
    "Share new workflows with team"
  ]
}
```

---

## Step 8: Update Mobile-Cline-Bank Repository

**Action:** If new platform/project created, update the repository

**Process:**

### 8A. Check for New Content
```
Checking for repository updates needed...

New Content Detected:
✓ New platform folder: Workflows/projects/windows/
✓ New project folder: Workflows/projects/android/authsdk/
✓ Generated workflows: 6 files
✓ Rules added: Rules/windows/ (3 files)
```

### 8B. Update Project README Files

**Update `Workflows/projects/README.md`:**
- Add new platform section
- Add new project to appropriate platform section
- Update file structure diagram

**Update `Workflows/projects/<platform>/README.md`:**
- Add new project entry with description
- Update project list

### 8C. Self-Update This Workflow

**Update `Workflows/configuration/cline-bank-setup-dynamic.md` (this file):**

**Update platform list in Step 1:**
```markdown
**Dynamic Options:**
Current Platforms:
1. Android
2. iOS  
3. Windows (NEW!)
4. MacOS (NEW!)     ← Added
5. Native (C/C++)
---
6. Add New Platform
```

**Update example project lists:**
```markdown
**For Windows:**
- dotnetapp - .NET Core Application
- wpfapp - WPF Desktop Application
```

### 8D. Inform User of Repository Changes

**Display:**
```
📝 Mobile-Cline-Bank Repository Updated
==========================================

New Content Added:
1. Platform: Windows
   - Rules/windows/ (3 files)
   - Workflows/projects/windows/ (folder created)

2. Project: authsdk (Android Authentication SDK)
   - 6 generated workflows
   - Project README

3. Documentation Updated:
   - Workflows/projects/README.md
   - Workflows/projects/android/README.md
   - This workflow (cline-bank-setup-dynamic.md)

⚠️ IMPORTANT: You should commit these changes to mobile-cline-bank:

   cd mobile-cline-bank
   git add Rules/windows Workflows/projects/android/authsdk
   git add Workflows/projects/README.md Workflows/projects/android/README.md
   git commit -m "Add Windows platform and authsdk project with generated workflows"
   git push origin main

This makes the new platform/project available to the entire team.
```

---

## Step 9: Post-Setup Instructions

**Action:** Display completion summary and next steps

**Display:**
```
✅ Setup Complete!

Your Cline rules and workflows have been configured.

📁 Files Location:
   .clinerules/rules/      - All rules files
   .clinerules/workflows/  - All workflow files
   .clinerules/MCP/        - MCP configuration

📝 Configuration saved to:
   .clinerules/cline-bank-config.json
```

**For Standard Setup:**
```
🔄 To update or modify your configuration:
   - "update cline bank" - Sync with latest changes
   - "modify cline bank" - Change your selections
   - "review cline bank config" - See current setup

📚 Next Steps:
   1. Review .clinerules/MCP/cline_mcp_settings.template.json
   2. Configure environment variables for Jira/Confluence (if using)
   3. Try a workflow: "git commit" or "build sdk"

💡 Tip: Use "list workflows" to see all available workflows
```

**For New Platform Setup:**
```
⚠️ New Platform Created: <platform>

📋 TODO - Complete Platform Setup:
   1. Add coding rules to mobile-cline-bank/Rules/<platform>/
      - Create <language>-rules.md files
      - Follow examples from Rules/android/ or Rules/ios/
      - Include condensed versions in Rules/<platform>/condensed/
   
   2. Update mobile-cline-bank repository:
      - Commit new platform structure
      - Push to share with team
   
   3. Re-run setup to include platform rules:
      - "setup cline bank"
      - Select the new platform
      - Rules will now be available

📚 Reference:
   - See Rules/android/README.md for structure example
   - See Workflows/projects/README.md for workflow guidelines
```

**For New Project Noted:**
```
⚠️ New Project Noted: <short-name> (<full-name>)

📋 Next Steps - Initialize Memory Bank & Generate Workflows:
   
   1. Initialize the Memory Bank:
      - Work with Cline on your project tasks
      - Let Cline learn your project structure, dependencies, and conventions
      - This helps create accurate, project-specific workflows
   
   2. Generate Project Workflows:
      - Command: 'create project workflows'
      - Cline will analyze your initialized memory bank
      - Generate workflows tailored to your actual codebase
      - Workflows will be added to mobile-cline-bank
   
   3. Update Your Configuration:
      - Run 'update cline bank' to include new workflows
      - Workflows will be copied to .clinerules/workflows/project/
   
   4. Share with Team (Optional):
      - Commit workflows to mobile-cline-bank repository
      - Make them available to your team

💡 Why This Approach:
   - Accurate workflows based on real project structure
   - Better understanding of build processes and dependencies
   - Tailored trigger patterns that match your workflow
   - Complete and context-aware workflow generation
```

---

## Workflow Auto-Generation Rules

Based on `Workflows/projects/README.md`, workflows are generated with:

### Naming Conventions
- Use lowercase with hyphens: `build-sdk.md`, `run-tests.md`
- Action-first naming: `build-`, `test-`, `deploy-`, `check-`

### Standard Workflows by Type

**SDK/Library:**
1. `build-sdk.md` - Build SDK artifacts (AAR, JAR, framework)
2. `test-sdk.md` - Run unit and instrumentation tests
3. `check-quality.md` - Lint, code quality, static analysis
4. `clean-build.md` - Clean build artifacts and caches
5. `install-library.md` - Install to local repository for testing
6. `release-sdk.md` - Create release package with versioning

**Application:**
1. `build-app.md` - Build application
2. `run-tests.md` - Run test suites (unit, integration, UI)
3. `run-quality-checks.md` - Code quality and lint checks
4. `create-release-package.md` - Package for distribution
5. `run-security-scan.md` - Security scanning (if applicable)

**Service/Backend:**
1. `build-service.md` - Build service
2. `run-tests.md` - Run test suites
3. `deploy-local.md` - Deploy to local environment
4. `check-quality.md` - Code quality checks
5. `create-docker-image.md` - Build Docker container

### Workflow Template Structure

Each generated workflow follows this structure:

```markdown
# [Action] [Project Name]

Brief description of what this workflow does.

## Trigger Patterns
- <action> <project>
- <action> the <type>

## Prerequisites
- Requirement 1
- Requirement 2

## Steps
1. Step 1: Validate prerequisites
2. Step 2: Perform main action
3. Step 3: Report results

## Examples
User: <trigger pattern>

## Troubleshooting
Common Issue 1: Solution
Common Issue 2: Solution
```

---

## Self-Updating Mechanism

This workflow updates itself when:
1. New platforms are added
2. New projects are created
3. Structure changes require documentation updates

**Update Locations:**
- Step 1: Platform list
- Step 2: Project examples per platform
- File structure diagrams
- Example configurations

**Update Process:**
1. Detect changes (new folders in `Rules/` or `Workflows/projects/`)
2. Generate updated sections
3. Replace outdated content while preserving structure
4. Add version note in changelog

---

## Error Handling

### New Platform - Missing Rules
**Error:** Platform created but no rules added yet

**Action:**
1. Continue setup with common rules only
2. Note in config: `"platformStatus": "new"`
3. Add to pending actions
4. Display reminder in post-setup

**Message:**
```
⚠️ Platform '<platform>' has no specific rules yet.

Setup will continue with common rules only.
Add platform rules later and run 'update cline bank'.
```

### New Project - Generation Failed
**Error:** Cannot generate workflows

**Action:**
1. Create project folder structure
2. Create minimal README
3. Note in config: `"projectWorkflowsGenerated": false`
4. Ask user to manually add workflows

**Message:**
```
⚠️ Could not auto-generate workflows for '<project>'.

Please manually create workflows in:
  mobile-cline-bank/Workflows/projects/<platform>/<project>/

Then run 'update cline bank' to include them.
```

### Repository Update Failed
**Error:** Cannot update mobile-cline-bank

**Action:**
1. Complete setup without repo updates
2. Note in config: `"requiresRepoUpdate": true`
3. Provide manual instructions

**Message:**
```
⚠️ Could not update mobile-cline-bank repository automatically.

Manual steps required:
1. Review changes in mobile-cline-bank/
2. Commit new platform/project content
3. Push to share with team
```

---

## Version History

**v2.0.0** (2026-01-27)
- Dynamic platform discovery and creation
- Dynamic project discovery and creation
- Workflow auto-generation
- Self-updating capability
- Mobile-cline-bank repository management
- Enhanced error handling

**v1.0.0** (2026-01-26)
- Initial static version
- Support for Android platform
- Support for 3 Android projects
- Configuration management

---

## Related Documentation

- **Original Setup:** `cline-bank-setup.md` (static version)
- **Project Workflow Rules:** `../projects/README.md`
- **Workflow Standards:** `workflow-standards.md`
- **SETUP-GUIDE:** `../../SETUP-GUIDE.md`

---

**Workflow Type:** Intelligent & Self-Updating  
**Behavior:** Simple for existing setups, extended only when creating new platforms/projects  
**Maintenance:** Automatic + Manual Review Quarterly  
**Last Review:** 2026-01-27  
**Next Review:** 2026-04-27
