# AGENTS.md

This file provides comprehensive documentation for AI agents working with the SwiftPruebas codebase.

**Current Version**: 1.0 (February 2026)

---

## Project Overview

SwiftPruebas is an AI-powered regression testing library for macOS and iOS applications. It enables developers to write tests in human-readable YAML/Gherkin format and automatically generates XCUITest code using AI (Claude Sonnet 4.5).

**Key Value Proposition**: Write tests in plain English, let AI generate the XCUITest code, run tests locally or in CI, get screenshots and reports automatically.

**Platforms**: macOS 26.0+ / iOS 26.0+

---

## Project Structure

```
SwiftPruebas/
├── SwiftPruebas/              # macOS app target
│   ├── Views/                 # SwiftUI views (scenario editor, test runner, results)
│   ├── Models/                # Data models with SwiftData
│   └── Services/              # Business logic services
├── scenario-runner/           # CLI tool target (headless runner for CI/CD)
│   ├── Commands/              # ArgumentParser commands (run, generate, validate, list)
│   └── Utilities/             # Helper utilities
├── SwiftPruebasCore/          # Shared framework
│   ├── ScenarioParser.swift   # YAML scenario parser
│   ├── AITestGenerator.swift  # Claude API integration for test generation
│   ├── AppIntentDiscovery.swift  # Discovers App Intents from target apps
│   └── TestRunner.swift       # XCUITest execution engine
├── Tests/
│   ├── Scenarios/             # YAML test scenarios (human-readable)
│   ├── Generated/             # AI-generated XCUITest Swift code
│   └── Fixtures/              # Test data files (fountain, JSON, etc.)
└── Docs/
    ├── AI_POWERED_TESTING_ARCHITECTURE.md  # Complete architecture documentation
    ├── PLATFORM-ENFORCEMENT.md             # Platform version rules
    └── QUICK-START-ENFORCEMENT.md          # Quick start guide
```

---

## Key Components

### 1. Test Scenario Format (YAML/Gherkin)

SwiftPruebas uses YAML files with Gherkin-style syntax for test scenarios:

```yaml
scenario: Complete FCPXML Export Workflow
description: Tests the full workflow from document open to FCPXML bundle creation
tags: [fcpxml, export, regression, critical]
timeout: 300  # seconds
platforms: [macOS, iOS]

setup:
  - Given a test screenplay file at "Fixtures/test-screenplay.fountain"
  - And the test export directory is clean

steps:
  - Given the app is launched
  - When I open the document "Fixtures/test-screenplay.fountain"
  - Then the document should be loaded successfully
  - When I export to Final Cut Pro at "/tmp/test-export.fcpxmlbundle"
  - Then the export should complete successfully
  - And the bundle should exist at "/tmp/test-export.fcpxmlbundle"

teardown:
  - Clean up test exports
  - Close all documents

validation:
  screenshots: true  # Take screenshots at each step
  logs: true         # Capture console logs
  performance: true  # Track memory and CPU
```

**Gherkin Keywords**:
- **Given** - Set up preconditions
- **When** - Perform actions
- **Then** - Assert expected outcomes
- **And/But** - Chain multiple steps

### 2. AI Test Generator (Claude Sonnet 4.5)

**Purpose**: Converts YAML scenarios into executable XCUITest Swift code

**Key Features**:
- Analyzes available App Intents before generating code
- Prefers App Intent calls over UI automation for speed and stability
- Adds XCTAssert statements for all "Then" steps
- Includes descriptive comments explaining each test step
- Handles timeouts and async operations properly
- Takes screenshots at validation points when requested

**API Integration**:
- Primary AI model: Claude Sonnet 4.5 via Anthropic API
- API key stored securely in Keychain (macOS app) or environment variables (CLI)
- Prompt engineering focuses on generating stable, maintainable XCUITest code

### 3. App Intent Discovery

**Purpose**: Discovers testable functionality exposed by target apps via App Intents

**Discovery Process**:
1. Find app bundle by bundle identifier
2. Read `AppIntents.json` manifest from app's Resources folder
3. Extract intent signatures (name, parameters, return type)
4. Provide intent catalog to AI generator for context

**Target App Requirements**:
Target apps should expose key functionality via App Intents and provide a manifest:

```json
[
  {
    "name": "OpenDocumentIntent",
    "parameters": [
      {"name": "filePath", "type": "String", "isOptional": false}
    ],
    "returnType": "String",
    "description": "Opens a document and returns its ID"
  }
]
```

### 4. XCUITest Code Generation

Generated tests follow this pattern:
- Import XCTest
- Define test class inheriting from XCTestCase
- setUp/tearDown methods for test lifecycle
- Test methods with descriptive names based on scenario
- App Intent calls for business logic
- XCUITest for UI validation only
- XCTAssert statements for all assertions
- Screenshots at critical points

### 5. SwiftPruebas macOS App

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

### 6. scenario-runner CLI

**Purpose**: Headless test runner for CI/CD pipelines

**Key Commands**:

| Command | Purpose | Key Flags |
|---------|---------|-----------|
| `run` | Execute test scenarios | `--all`, `--scenario`, `--tags`, `--app`, `--ci-mode`, `--parallel`, `--report-format` |
| `generate` | Generate XCUITest code from scenarios | `--scenario`, `--scenarios-dir`, `--output`, `--ai-api-key`, `--force` |
| `validate` | Validate scenario syntax | `--scenarios-dir`, `--strict` |
| `list` | List available scenarios | `--scenarios-dir`, `--format`, `--tags` |

**Example Usage**:

```bash
# Run all scenarios
scenario-runner run --all --app "com.example.YourApp" --ci-mode

# Run scenarios by tag
scenario-runner run --tags "critical,regression" --app "YourApp"

# Generate HTML report
scenario-runner run --all --app "YourApp" \
  --report-format html --output test-report.html

# Generate tests without running
scenario-runner generate --scenario "export-fcpxml.yaml" \
  --output Tests/Generated/
```

---

## Architecture and Design Patterns

### Test Generation Pipeline

```
1. YAML Scenario (human-readable)
   ↓
2. ScenarioParser → TestScenario struct
   ↓
3. AppIntentDiscovery → AppContext (available intents)
   ↓
4. AITestGenerator (Claude API)
   - Receives: scenario + app context
   - Generates: Swift XCUITest code
   ↓
5. Generated XCUITest Swift code
   - App Intent calls for business logic
   - XCUITest for UI validation
   ↓
6. TestRunner → Execute via XCTest
   ↓
7. Results + Screenshots + Reports
```

### Key Design Patterns

1. **Protocol-Oriented Design**: Extensibility for different AI providers, test runners
2. **Dependency Injection**: Testability for core components
3. **Async/Await**: Swift concurrency throughout
4. **Actor-Based**: Safe concurrent access to shared state
5. **SwiftData**: Persistence for macOS app (scenarios, results, settings)

### App Intent Integration Strategy

**Why App Intents?**
- **Speed**: Bypass slow UI interactions
- **Stability**: Programmatic APIs don't break when UI changes
- **Reliability**: No timing issues or flaky UI searches

**Test Generation Priority**:
1. Use App Intents for business logic (preferred)
2. Use XCUITest only for UI validation (buttons exist, labels show correct text)
3. Graceful fallback to pure UI automation when intents unavailable

---

## Platform Version Enforcement

**CRITICAL**: This project ONLY supports iOS 26.0+ and macOS 26.0+. NEVER add code that supports older platforms.

### Rules for Platform Versions

1. **NEVER add `@available` attributes** for versions below iOS 26.0 or macOS 26.0
   - ❌ WRONG: `@available(iOS 15.0, macOS 12.0, *)`
   - ✅ CORRECT: No `@available` needed (project enforces iOS 26/macOS 26)

2. **NEVER add `#available` runtime checks** for versions below iOS 26.0 or macOS 26.0
   - ❌ WRONG: `if #available(iOS 15.0, *) { ... }`
   - ✅ CORRECT: No runtime checks needed (project enforces minimum versions)

3. **Platform-specific code is OK** (macOS vs iOS differences)
   - ✅ CORRECT: `#if os(macOS)` or `#if canImport(AppKit)`
   - ✅ CORRECT: `#if canImport(UIKit)`
   - ❌ WRONG: Checking for specific OS versions below 26

**DO NOT lower the platform requirements. This is an Xcode project targeting macOS 26+ and iOS 26+.**

See `Docs/PLATFORM-ENFORCEMENT.md` for complete enforcement rules.

---

## Swift Style and Conventions

### Language Features

- **Swift 6.0+** with strict concurrency enabled
- **Async/await** over completion handlers
- **Structured concurrency** (TaskGroup, async let) where appropriate
- **Sendable conformance** for all types crossing concurrency boundaries
- **Actor isolation** for mutable shared state

### Code Style

- Follow Swift API Design Guidelines
- Use descriptive variable and function names
- Prefer value types (structs) over reference types (classes) when appropriate
- Use extensions to organize code by functionality
- Document public APIs with DocC-style comments

### Testing Approach

- Write tests that use App Intents for business logic when possible
- Use XCUITest only for UI validation
- Generate screenshot evidence at critical test points
- Include comprehensive error handling with descriptive messages

---

## Development Guidelines

### When Adding Features

1. **Read existing code first** - Understand the current implementation before making changes
2. **Maintain consistency** - Follow existing patterns and conventions
3. **Update tests** - Add/update tests for new functionality
4. **Document changes** - Update relevant documentation files (this file, architecture doc)
5. **Consider CI/CD** - Ensure changes work in headless environments

### When Generating Test Code (AI)

The AI test generator should:
- Analyze available App Intents before generating code
- Prefer App Intent calls over UI automation
- Add XCTAssert statements for all "Then" steps
- Include descriptive comments explaining each test step
- Handle timeouts and async operations properly
- Take screenshots at validation points when requested
- Use proper error handling with descriptive failure messages

### When Writing Scenarios

- Use clear, concise Gherkin language
- Include necessary setup and teardown steps
- Add relevant tags for test organization
- Specify realistic timeouts
- Document expected outcomes for AI context
- Provide fixture file paths when needed

### Security Considerations

- **Never commit API keys to version control**
- Use Keychain for credential storage in macOS app
- Use environment variables for CLI tool
- Validate all file paths to prevent directory traversal
- Sanitize user input in generated test code
- Use secure defaults for all configurations

### Performance Optimization

- Use App Intents to bypass slow UI interactions
- Support parallel test execution in CLI
- Cache AI-generated tests to avoid redundant API calls
- Implement incremental test regeneration (only changed scenarios)
- Use efficient screenshot compression and storage

---

## Common Tasks

### Adding a New Scenario

1. Create YAML file in `Tests/Scenarios/`
2. Validate syntax: `scenario-runner validate --scenarios-dir Tests/Scenarios`
3. Generate test: `scenario-runner generate --scenario Tests/Scenarios/your-scenario.yaml`
4. Review generated code in `Tests/Generated/`
5. Run test: `scenario-runner run --scenario Tests/Scenarios/your-scenario.yaml`

### Implementing a New App Intent (Target App)

1. Create intent in target app's Shortcuts folder
2. Add intent info to `AppIntents.json` manifest
3. Test intent manually using Shortcuts app
4. Reference intent in test scenarios
5. Verify AI generator uses the intent properly

### Extending the AI Generator

1. Update prompt template in `AITestGenerator.swift`
2. Add context extraction methods if needed
3. Update code parsing/validation logic
4. Test with various scenario types
5. Update documentation with new capabilities

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Regression Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-26  # ALWAYS use macos-26 or later

    steps:
      - uses: actions/checkout@v4

      - name: Run SwiftPruebas tests
        env:
          PRUEBAS_AI_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          swift run scenario-runner run \
            --all \
            --app "com.yourcompany.YourApp" \
            --report-format html \
            --output test-report.html \
            --ci-mode

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: |
            test-report.html
            screenshots/
```

**CRITICAL CI/CD Rules**:
- **ALWAYS use `macos-26` or later** for the `runs-on:` runner
- **NEVER use older versions** like `macos-15`, `macos-14`, etc.
- **Swift version must be 6.2 or later**

See global `CLAUDE.md` instructions for complete CI/CD guidelines including iOS simulator configuration and branch protection rules.

---

## Build and Test

**CRITICAL**: This library must ONLY be compiled using `xcodebuild`. Do NOT use `swift build` or `swift test`.

```bash
# Build the project
xcodebuild -scheme SwiftPruebas -destination 'platform=macOS,arch=arm64' build

# Run tests
xcodebuild -scheme SwiftPruebas -destination 'platform=macOS,arch=arm64' test

# Build CLI tool
xcodebuild -scheme scenario-runner -destination 'platform=macOS,arch=arm64' build
# Binary at DerivedData/SwiftPruebas-*/Build/Products/Debug/scenario-runner
```

---

## Troubleshooting

### Test Generation Issues

- Verify API key is configured correctly
- Check AppIntents.json exists and is valid
- Ensure target app is installed and accessible
- Review AI generator logs for errors
- Try regenerating with `--force` flag

### Test Execution Issues

- Verify app bundle identifier is correct
- Check app permissions (Accessibility, Automation)
- Ensure test fixtures exist at specified paths
- Review test timeout settings
- Check XCTest logs for detailed errors

### CI/CD Issues

- Verify macOS runner version is 26 or later
- Check Swift version is 6.2 or later
- Ensure API key secret is configured
- Review GitHub Actions logs for detailed errors
- Test locally before pushing to CI

---

## Development Roadmap

### Phase 1: Core Infrastructure (Current)
- YAML scenario parser implementation
- Claude API integration for test generation
- App Intent discovery system
- XCUITest code generation engine
- Basic CLI runner functionality

### Phase 2: macOS App
- Scenario editor UI
- Test runner integration
- Results viewer
- Screenshot gallery

### Phase 3: Advanced Features
- Parallel test execution
- Visual regression detection
- Performance metrics
- Test history tracking

### Phase 4: AI Enhancements
- Self-healing tests (AI fixes broken tests)
- Test suggestion engine
- Scenario generation from user stories

### Phase 5: Ecosystem
- VS Code extension
- Xcode extension
- Web dashboard
- Public scenario library

See `Docs/AI_POWERED_TESTING_ARCHITECTURE.md` for complete roadmap and architecture details.

---

## References

For detailed information, refer to:
- [AI_POWERED_TESTING_ARCHITECTURE.md](Docs/AI_POWERED_TESTING_ARCHITECTURE.md) - Complete system architecture
- [PLATFORM-ENFORCEMENT.md](Docs/PLATFORM-ENFORCEMENT.md) - Platform version enforcement rules
- [QUICK-START-ENFORCEMENT.md](QUICK-START-ENFORCEMENT.md) - Quick start guide
- [README.md](README.md) - Project overview and usage examples

---

## Benefits Summary

### For Developers
- Write tests in plain English, not verbose XCUITest code
- Tests auto-update when features change (regenerate from scenarios)
- Fast test execution (App Intents bypass UI when possible)
- Visual feedback with screenshots
- CI-friendly (runs headless on GitHub Actions)

### For QA Engineers
- Create tests without coding knowledge
- Maintainable scenarios (YAML is human-readable)
- Comprehensive test coverage with minimal effort
- Visual regression detection
- Test reports for stakeholders

### For Product Managers
- Scenarios document expected behavior
- Acceptance criteria as executable tests
- Confidence in releases (comprehensive regression suite)
- Reduced manual testing burden
- Faster iteration cycles

---

**End of Document**
