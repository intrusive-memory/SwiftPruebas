# AI-Powered Testing Architecture for SwiftPruebas

**Version**: 1.0
**Status**: Architecture Document
**Last Updated**: 2025-12-02

---

## Executive Summary

SwiftPruebas is a testing library that enables AI-powered regression testing for macOS and iOS applications. It combines human-readable test scenarios (YAML/Gherkin) with AI-generated XCUITest code to create maintainable, robust test suites that evolve with your app.

**Key Value Proposition**: Write tests in plain English, let AI generate the XCUITest code, run tests locally or in CI, get screenshots and reports automatically.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Components](#components)
3. [Test Scenario Format](#test-scenario-format)
4. [AI Test Generator](#ai-test-generator)
5. [SwiftPruebas App (macOS)](#swiftpruebas-app-macos)
6. [scenario-runner (CLI)](#scenario-runner-cli)
7. [App Intents Integration](#app-intents-integration)
8. [CI/CD Integration](#cicd-integration)
9. [Development Roadmap](#development-roadmap)

---

## Architecture Overview

### The Problem

Traditional UI testing is:
- **Brittle**: Tests break when UI changes
- **Slow to write**: Requires writing verbose XCUITest code
- **Hard to maintain**: Updating tests after feature changes is painful
- **Not human-readable**: Stakeholders can't understand test code

### The Solution

```
┌─────────────────────────────────────────────────────────┐
│                   Test Scenarios (YAML)                  │
│           Human-readable, version-controlled             │
│           scenario: Export to FCPXML                     │
│           steps:                                         │
│             - Given a test screenplay file               │
│             - When I export to Final Cut Pro             │
│             - Then the bundle should exist               │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│              AI Test Generator (Claude)                  │
│         Converts scenarios → XCUITest code               │
│         - Understands app context                        │
│         - Generates Swift code                           │
│         - Uses App Intents for stability                 │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│               Generated XCUITests (Swift)                │
│         App Intent calls + UI validation                 │
│         - Fast (bypasses UI when possible)               │
│         - Stable (uses programmatic APIs)                │
│         - Screenshots on failure                         │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                 Xcode Test Runner                        │
│         Local dev / GitHub Actions / CI                  │
│         - Headless execution                             │
│         - Parallel test runs                             │
│         - Result bundles with screenshots                │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│            Results + Screenshots + Reports               │
│         HTML reports, Slack notifications                │
│         - Visual regression detection                    │
│         - Performance metrics                            │
│         - Test history tracking                          │
└─────────────────────────────────────────────────────────┘
```

---

## Components

### 1. SwiftPruebas (macOS App)

**Purpose**: Visual scenario editor and test runner

**Features**:
- Scenario editor with syntax highlighting
- Live preview of generated tests
- Run tests with visual feedback
- Screenshot gallery
- Test results dashboard
- Scenario library management

**Technology Stack**:
- SwiftUI for UI
- SwiftData for persistence
- AppKit integration for file management
- XCTest integration for running tests

### 2. scenario-runner (Command-Line Tool)

**Purpose**: Headless test runner for CI/CD

**Features**:
- Run individual scenarios or entire suites
- JSON/HTML report generation
- Screenshot extraction
- Exit codes for CI integration
- Progress reporting
- Parallel execution

**Technology Stack**:
- Swift ArgumentParser
- XCTest programmatic API
- Foundation for file I/O

### 3. SwiftPruebas Framework

**Purpose**: Core testing infrastructure

**Features**:
- YAML scenario parser
- AI test generator client
- App Intent discovery
- XCUITest code generator
- Result aggregation
- Screenshot management

---

## Test Scenario Format

### YAML Structure

```yaml
# Scenario metadata
scenario: Complete FCPXML Export Workflow
description: Tests the full workflow from document open to FCPXML bundle creation
tags: [fcpxml, export, regression, critical]
timeout: 300  # seconds
platforms: [macOS, iOS]  # Which platforms this test applies to

# Pre-test setup
setup:
  - Given a test screenplay file at "Fixtures/test-screenplay.fountain"
  - And the user has a PRO subscription
  - And all voice providers are configured
  - And the test export directory is clean

# Test steps (Gherkin-style)
steps:
  # Given (preconditions)
  - Given the app is launched

  # When (actions)
  - When I open the document "Fixtures/test-screenplay.fountain"
  - Then the document should be loaded successfully
  - And the document should have 50 elements

  - When I assign voice "hablare://apple/com.apple.voice.compact.en-US.Samantha" to character "ALICE"
  - And I assign voice "hablare://apple/com.apple.voice.compact.en-US.Tom" to character "BOB"
  - Then the voice mappings should be saved

  - When I generate audio for "all" elements
  - Then I should wait up to 120 seconds for generation to complete
  - And the document should have 50 generated audio files

  - When I export to Final Cut Pro at "/tmp/test-export.fcpxmlbundle" with chapter level "scene"
  - Then the export should complete successfully
  - And the bundle should exist at "/tmp/test-export.fcpxmlbundle"
  - And the bundle should contain an FCPXML file
  - And the bundle should contain 50 audio assets
  - And the FCPXML should have valid XML syntax
  - And the FCPXML should use relative paths only
  - And the FCPXML should have chapter markers

# Post-test cleanup
teardown:
  - Clean up test exports
  - Reset voice mappings
  - Close all documents

# Validation options
validation:
  screenshots: true  # Take screenshots at each step
  logs: true  # Capture console logs
  performance: true  # Track memory and CPU
  retry_on_failure: 1  # Retry failed tests once

# Expected results (for AI context)
expected_outcomes:
  - Document opens without errors
  - Audio generation completes within timeout
  - Export creates valid FCPXML bundle
  - All assets present and valid
```

### Gherkin Keywords

**Given** - Set up preconditions
```yaml
- Given a test screenplay file at "path/to/file.fountain"
- Given the user has a PRO subscription
- Given the app is in dark mode
```

**When** - Perform actions
```yaml
- When I click the "Export" button
- When I enter "Test Project" in the title field
- When I select "Scene Heading" from the chapter level picker
```

**Then** - Assert expected outcomes
```yaml
- Then the export should complete successfully
- Then the bundle should exist at "/tmp/test.fcpxmlbundle"
- Then the FCPXML should contain 50 audio clips
```

**And/But** - Chain multiple steps
```yaml
- And the document should have 50 elements
- But the document should not have any errors
```

---

## AI Test Generator

### Overview

The AI Test Generator converts YAML scenarios into executable XCUITest Swift code using Claude API (or compatible LLM).

### Architecture

```swift
// SwiftPruebas/TestGenerator/AITestGenerator.swift

protocol AITestGenerator {
    func generate(scenario: TestScenario, context: AppContext) async throws -> GeneratedTest
}

struct ClaudeTestGenerator: AITestGenerator {
    let apiKey: String
    let model: String = "claude-sonnet-4-5"

    func generate(scenario: TestScenario, context: AppContext) async throws -> GeneratedTest {
        let prompt = buildPrompt(scenario: scenario, context: context)
        let response = try await callClaudeAPI(prompt: prompt)
        let swiftCode = extractSwiftCode(from: response)

        return GeneratedTest(
            scenario: scenario,
            swiftCode: swiftCode,
            generatedAt: Date()
        )
    }

    private func buildPrompt(scenario: TestScenario, context: AppContext) -> String {
        """
        Generate a Swift XCUITest class for the following test scenario.

        **Context:**
        - App Name: \(context.appName)
        - Target App: \(context.bundleIdentifier)
        - Platform: \(context.platform)
        - Available App Intents: \(context.availableIntents.map { $0.name }.joined(separator: ", "))

        **App Intent Signatures:**
        \(context.availableIntents.map { intent in
            """
            - \(intent.name)
              Parameters: \(intent.parameters.map { "\($0.name): \($0.type)" }.joined(separator: ", "))
              Returns: \(intent.returnType)
            """
        }.joined(separator: "\n"))

        **Scenario:**
        Name: \(scenario.name)
        Description: \(scenario.description ?? "")
        Tags: \(scenario.tags.joined(separator: ", "))
        Timeout: \(scenario.timeout)s

        **Setup:**
        \(scenario.setup.map { "- \($0)" }.joined(separator: "\n"))

        **Steps:**
        \(scenario.steps.map { "- \($0)" }.joined(separator: "\n"))

        **Teardown:**
        \(scenario.teardown.map { "- \($0)" }.joined(separator: "\n"))

        **Requirements:**
        1. Use App Intents for business logic (fast, stable) whenever possible
        2. Use XCUITest only for UI validation (buttons exist, progress shown, etc.)
        3. Add XCTAssert statements for all "Then" steps
        4. Take screenshots at critical points if validation.screenshots is true
        5. Include proper error handling and timeouts
        6. Add descriptive test method name based on scenario name
        7. Use the provided App Intents (don't make up new ones)
        8. Follow Swift 6.0+ best practices with strict concurrency
        9. Use async/await for all asynchronous operations
        10. Add detailed inline comments explaining each step

        **Output Format:**
        Provide a complete Swift test class ready to run in Xcode.
        Include imports, class definition, setUp/tearDown, and test method.
        """
    }
}
```

### App Context Discovery

```swift
// SwiftPruebas/TestGenerator/AppContextDiscovery.swift

struct AppContextDiscovery {
    func discover(for bundleID: String) async throws -> AppContext {
        // 1. Find app bundle
        let appPath = try findAppBundle(bundleID: bundleID)

        // 2. Discover App Intents via reflection
        let intents = try discoverAppIntents(at: appPath)

        // 3. Extract app metadata
        let metadata = try extractAppMetadata(at: appPath)

        return AppContext(
            appName: metadata.displayName,
            bundleIdentifier: bundleID,
            platform: metadata.platform,
            availableIntents: intents
        )
    }

    private func discoverAppIntents(at appPath: String) throws -> [AppIntentInfo] {
        // Use runtime reflection or metadata extraction
        // to discover all App Intents exposed by the target app

        // For now, could use a manifest file that apps provide
        let manifestPath = "\(appPath)/Contents/Resources/AppIntents.json"
        guard FileManager.default.fileExists(atPath: manifestPath) else {
            return []
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: manifestPath))
        return try JSONDecoder().decode([AppIntentInfo].self, from: data)
    }
}

struct AppIntentInfo: Codable {
    let name: String
    let parameters: [ParameterInfo]
    let returnType: String
    let description: String
}

struct ParameterInfo: Codable {
    let name: String
    let type: String
    let isOptional: Bool
}
```

---

## SwiftPruebas App (macOS)

### Main Window Layout

```
┌─────────────────────────────────────────────────────────────┐
│  File  Edit  View  Test  Window  Help                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┬───────────────────────────────────────┐    │
│  │  Scenarios  │  Scenario: Export FCPXML               │    │
│  │             │                                         │    │
│  │  ✅ Basic   │  scenario: Complete FCPXML Export      │    │
│  │  📝 Export  │  tags: [fcpxml, export, critical]      │    │
│  │  🎵 Audio   │                                         │    │
│  │  🎬 FCP     │  steps:                                 │    │
│  │  👥 Casting │    - Given a test screenplay...        │    │
│  │             │    - When I export to Final Cut Pro... │    │
│  │  + New      │    - Then the bundle should exist...   │    │
│  │             │                                         │    │
│  │  [Run All]  │  [Edit] [Generate Test] [Run]          │    │
│  └─────────────┴───────────────────────────────────────┘    │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Test Results                                          │  │
│  │                                                          │  │
│  │  ✅ Export FCPXML - Passed (12.3s)                     │  │
│  │     ├─ Document opened (0.5s)                          │  │
│  │     ├─ Audio generated (10.2s)                         │  │
│  │     └─ Export completed (1.6s)                         │  │
│  │                                                          │  │
│  │  [View Screenshots] [View Logs] [Export Report]       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Key Features

#### 1. Scenario Management
- Create/edit/delete scenarios
- Organize by tags and folders
- Search and filter
- Duplicate scenarios

#### 2. Scenario Editor
- Syntax highlighting for YAML
- Auto-completion for Gherkin keywords
- Live validation
- Template library

#### 3. Test Generation
- One-click generate from scenario
- View generated Swift code
- Edit generated code if needed
- Regenerate after scenario changes

#### 4. Test Execution
- Run individual scenarios
- Run tagged scenarios
- Run all scenarios
- Live progress display
- Console output

#### 5. Results Viewing
- Test success/failure status
- Execution time per step
- Screenshot gallery
- Log viewer
- Performance metrics

#### 6. Settings
- Configure AI API key
- Select target app
- Set test fixtures path
- Configure screenshot options
- CI integration settings

---

## scenario-runner (CLI)

### Usage

```bash
# Run all scenarios
scenario-runner run --all --app "Produciesta"

# Run specific scenario
scenario-runner run --scenario "fcpxml-export.yaml" --app "Produciesta"

# Run scenarios by tag
scenario-runner run --tags "critical,regression" --app "Produciesta"

# Generate report
scenario-runner run --all --app "Produciesta" --report-format html --output report.html

# CI mode (exit code based on results)
scenario-runner run --all --app "Produciesta" --ci-mode

# Generate tests without running
scenario-runner generate --scenario "fcpxml-export.yaml" --output Tests/Generated/

# Validate scenarios
scenario-runner validate --scenarios-dir Tests/Scenarios/

# List available scenarios
scenario-runner list --scenarios-dir Tests/Scenarios/
```

### Command Reference

#### `run` - Execute test scenarios

```bash
scenario-runner run [OPTIONS]

Options:
  --all                     Run all scenarios
  --scenario <file>         Run specific scenario file
  --scenarios-dir <path>    Path to scenarios directory (default: ./Tests/Scenarios)
  --tags <tag1,tag2>       Run scenarios with specific tags
  --exclude-tags <tags>     Exclude scenarios with tags
  --app <bundle-id>        Target app bundle identifier (required)
  --timeout <seconds>      Global timeout for all tests
  --parallel <count>       Run tests in parallel (default: 1)
  --report-format <fmt>    Report format: json, html, junit (default: json)
  --output <path>          Output path for report
  --screenshots-dir <path> Where to save screenshots
  --ci-mode                Exit with non-zero code on failure
  --verbose                Verbose output
  --dry-run                Show what would run without executing
```

#### `generate` - Generate XCUITest code from scenarios

```bash
scenario-runner generate [OPTIONS]

Options:
  --scenario <file>         Scenario to generate from
  --scenarios-dir <path>    Generate from all scenarios in directory
  --output <path>           Output directory for generated tests
  --ai-api-key <key>       AI API key (or use PRUEBAS_AI_API_KEY env var)
  --force                   Overwrite existing generated tests
```

#### `validate` - Validate scenario syntax

```bash
scenario-runner validate [OPTIONS]

Options:
  --scenarios-dir <path>    Path to scenarios directory
  --strict                  Strict validation (warnings as errors)
```

#### `list` - List available scenarios

```bash
scenario-runner list [OPTIONS]

Options:
  --scenarios-dir <path>    Path to scenarios directory
  --format <fmt>            Output format: table, json (default: table)
  --tags <tags>            Filter by tags
```

### Example CI Integration

```yaml
# .github/workflows/regression-tests.yml
name: Regression Tests

on:
  pull_request:
  push:
    branches: [main, development]
  schedule:
    - cron: '0 2 * * *'  # Nightly at 2 AM

jobs:
  test:
    runs-on: macos-15

    steps:
      - uses: actions/checkout@v4

      - name: Install scenario-runner
        run: |
          brew tap your-org/swiftpruebas
          brew install scenario-runner

      - name: Run regression tests
        env:
          PRUEBAS_AI_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          scenario-runner run \
            --all \
            --app "com.intrusive-memory.Produciesta" \
            --scenarios-dir Tests/Scenarios \
            --report-format html \
            --output test-report.html \
            --screenshots-dir screenshots \
            --ci-mode

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: |
            test-report.html
            screenshots/

      - name: Comment PR with results
        if: github.event_name == 'pull_request' && failure()
        uses: actions/github-script@v7
        with:
          script: |
            // Post test results to PR
```

---

## App Intents Integration

### For Target Apps (e.g., Produciesta)

To make your app testable with SwiftPruebas, expose key functionality via App Intents:

```swift
// In your app's Shortcuts/Testing directory

import AppIntents

@available(macOS 13.0, *)
struct OpenDocumentIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Document"

    @Parameter(title: "File Path")
    var filePath: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Business logic
        let documentID = try await DocumentManager.shared.open(path: filePath)
        return .result(value: documentID)
    }
}

// Export intent manifest for SwiftPruebas discovery
// AppIntents.json in Resources folder:
[
  {
    "name": "OpenDocumentIntent",
    "parameters": [
      {"name": "filePath", "type": "String", "isOptional": false}
    ],
    "returnType": "String",
    "description": "Opens a screenplay document and returns its ID"
  }
]
```

### Intent Discovery Protocol

```swift
// SwiftPruebas/AppIntentDiscovery/Protocol.swift

protocol AppIntentProvider {
    func availableIntents() -> [AppIntentInfo]
}

// Apps implement this to expose their intents
extension ProduciestaApp: AppIntentProvider {
    func availableIntents() -> [AppIntentInfo] {
        return [
            AppIntentInfo(name: "OpenDocumentIntent", ...),
            AppIntentInfo(name: "GenerateAudioIntent", ...),
            AppIntentInfo(name: "ExportToFCPXMLIntent", ...)
        ]
    }
}
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/pruebas.yml
name: SwiftPruebas Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4

      - name: Run tests
        env:
          PRUEBAS_AI_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          swift run scenario-runner run \
            --all \
            --app "YourApp" \
            --ci-mode
```

### Xcode Cloud

```json
// ci_scripts/ci_post_xcodebuild.sh
#!/bin/bash

# Run SwiftPruebas tests after Xcode build
swift run scenario-runner run \
  --all \
  --app "$APP_BUNDLE_ID" \
  --report-format junit \
  --output "$CI_DERIVED_DATA_PATH/test-results.xml"
```

---

## Development Roadmap

### Phase 1: Core Infrastructure (Week 1-2)
- [ ] YAML scenario parser
- [ ] Basic AI test generator (Claude API)
- [ ] App Intent discovery system
- [ ] XCUITest code generation
- [ ] Basic CLI runner

### Phase 2: macOS App (Week 3-4)
- [ ] Scenario editor UI
- [ ] Test runner integration
- [ ] Results viewer
- [ ] Screenshot gallery
- [ ] Settings management

### Phase 3: Advanced Features (Week 5-6)
- [ ] Parallel test execution
- [ ] Visual regression detection
- [ ] Performance metrics
- [ ] Test history tracking
- [ ] Cloud result storage

### Phase 4: AI Enhancements (Week 7-8)
- [ ] Self-healing tests (AI fixes broken tests)
- [ ] Test suggestion engine
- [ ] Scenario generation from user stories
- [ ] Natural language test queries

### Phase 5: Ecosystem (Week 9-10)
- [ ] VS Code extension
- [ ] Xcode extension
- [ ] Web dashboard
- [ ] Slack/Discord integration
- [ ] Public scenario library

---

## File Structure

```
SwiftPruebas/
├── SwiftPruebas/                      # macOS App
│   ├── SwiftPruebasApp.swift
│   ├── Views/
│   │   ├── ScenarioEditorView.swift
│   │   ├── TestRunnerView.swift
│   │   ├── ResultsView.swift
│   │   └── SettingsView.swift
│   ├── Models/
│   │   ├── TestScenario.swift
│   │   ├── TestResult.swift
│   │   └── AppContext.swift
│   └── Services/
│       ├── TestGeneratorService.swift
│       ├── TestRunnerService.swift
│       └── AppIntentDiscoveryService.swift
│
├── scenario-runner/                   # CLI Tool
│   ├── main.swift
│   ├── Commands/
│   │   ├── RunCommand.swift
│   │   ├── GenerateCommand.swift
│   │   ├── ValidateCommand.swift
│   │   └── ListCommand.swift
│   └── Utilities/
│       ├── ReportGenerator.swift
│       └── ScreenshotExtractor.swift
│
├── SwiftPruebasCore/                  # Shared Framework
│   ├── ScenarioParser.swift
│   ├── AITestGenerator.swift
│   ├── AppIntentDiscovery.swift
│   ├── XCUITestCodeGenerator.swift
│   └── TestRunner.swift
│
├── Tests/
│   ├── Scenarios/                     # Example scenarios
│   │   ├── basic-workflow.yaml
│   │   ├── export-fcpxml.yaml
│   │   └── casting-workflow.yaml
│   ├── Generated/                     # AI-generated tests
│   │   ├── BasicWorkflowTests.swift
│   │   └── ExportFCPXMLTests.swift
│   └── Fixtures/                      # Test data
│       ├── test-screenplay.fountain
│       └── cast-list.json
│
└── Docs/
    ├── AI_POWERED_TESTING_ARCHITECTURE.md  # This file
    ├── GETTING_STARTED.md
    ├── SCENARIO_FORMAT.md
    ├── APP_INTENT_INTEGRATION.md
    └── API_REFERENCE.md
```

---

## Benefits Summary

### For Developers
✅ Write tests in plain English, not verbose XCUITest code
✅ Tests auto-update when features change (regenerate from scenarios)
✅ Fast test execution (App Intents bypass UI when possible)
✅ Visual feedback with screenshots
✅ CI-friendly (runs headless on GitHub Actions)

### For QA Engineers
✅ Create tests without coding knowledge
✅ Maintainable scenarios (YAML is human-readable)
✅ Comprehensive test coverage with minimal effort
✅ Visual regression detection
✅ Test reports for stakeholders

### For Product Managers
✅ Scenarios document expected behavior
✅ Acceptance criteria as executable tests
✅ Confidence in releases (comprehensive regression suite)
✅ Reduced manual testing burden
✅ Faster iteration cycles

---

## Next Steps

1. Review this architecture document
2. Set up SwiftPruebas project structure
3. Implement Phase 1: Core Infrastructure
4. Create example scenarios for Produciesta
5. Generate and run first AI-powered tests
6. Iterate based on feedback

---

**End of Document**
