# SwiftPruebas

AI-powered regression testing for macOS and iOS applications. Write tests in plain English, let AI generate the XCUITest code.

## Requirements

- Swift 6.2+
- macOS 26.0+ / iOS 26.0+

## What is SwiftPruebas?

SwiftPruebas is a testing library that combines human-readable test scenarios (YAML/Gherkin) with AI-generated XCUITest code to create maintainable, robust test suites that evolve with your app.

### Key Features

- **Write tests in plain English** - No more verbose XCUITest code
- **AI-powered test generation** - Claude generates Swift test code from scenarios
- **App Intent integration** - Fast, stable tests using programmatic APIs
- **Visual feedback** - Automatic screenshots at validation points
- **CI/CD ready** - Headless execution in GitHub Actions and other CI platforms
- **Self-documenting** - Scenarios serve as living documentation

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/SwiftPruebas.git
cd SwiftPruebas

# Build the project
swift build

# Or open in Xcode
open SwiftPruebas.xcodeproj
```

### Create Your First Test Scenario

Create a YAML file in `Tests/Scenarios/`:

```yaml
# Tests/Scenarios/basic-workflow.yaml
scenario: Open and Export Document
description: Basic workflow to open a document and export it
tags: [smoke, critical]
timeout: 60

steps:
  - Given the app is launched
  - When I open the document "Fixtures/test-file.fountain"
  - Then the document should be loaded successfully
  - When I export to Final Cut Pro at "/tmp/test-export.fcpxmlbundle"
  - Then the export should complete successfully
  - And the bundle should exist at "/tmp/test-export.fcpxmlbundle"
```

### Generate and Run Tests

Using the CLI:

```bash
# Generate XCUITest code from scenario
swift run scenario-runner generate \
  --scenario Tests/Scenarios/basic-workflow.yaml \
  --output Tests/Generated/

# Run the generated test
swift run scenario-runner run \
  --scenario Tests/Scenarios/basic-workflow.yaml \
  --app "YourAppBundleID"
```

Using the macOS app:

1. Launch SwiftPruebas.app
2. Create or import a scenario
3. Click "Generate Test" to create XCUITest code
4. Click "Run" to execute the test
5. View results, screenshots, and logs

## Architecture

SwiftPruebas consists of three main components:

### 1. SwiftPruebas macOS App

Visual editor and test runner with:
- Scenario editor with syntax highlighting
- Live test generation and preview
- Test execution with visual feedback
- Screenshot gallery and log viewer
- Results dashboard

### 2. scenario-runner CLI

Command-line tool for CI/CD integration:
- Run scenarios individually or in batches
- Generate test code without running
- Validate scenario syntax
- Export results in multiple formats (JSON, HTML, JUnit)
- Parallel test execution

### 3. SwiftPruebasCore Framework

Shared infrastructure including:
- YAML scenario parser
- AI test generator (Claude API)
- App Intent discovery
- XCUITest code generation
- Test runner and result aggregation

## How It Works

```
┌─────────────────────────┐
│  YAML Test Scenario     │  ← Write in plain English
│  (Human-readable)       │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  AI Test Generator      │  ← Claude analyzes and generates
│  (Claude Sonnet 4.5)    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  XCUITest Swift Code    │  ← Ready to run
│  (App Intents + UI)     │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Test Execution         │  ← Fast, stable, visual
│  (Screenshots + Logs)   │
└─────────────────────────┘
```

## Usage Examples

### Run All Tests

```bash
scenario-runner run --all --app "YourApp" --ci-mode
```

### Run Tests by Tag

```bash
scenario-runner run --tags "critical,regression" --app "YourApp"
```

### Generate HTML Report

```bash
scenario-runner run \
  --all \
  --app "YourApp" \
  --report-format html \
  --output test-report.html
```

### Validate Scenarios

```bash
scenario-runner validate --scenarios-dir Tests/Scenarios/
```

### List Available Scenarios

```bash
scenario-runner list --scenarios-dir Tests/Scenarios/
```

## Scenario Format

Scenarios use YAML with Gherkin-style syntax:

```yaml
scenario: Name of your test
description: What this test validates
tags: [smoke, regression, critical]
timeout: 300  # seconds

setup:
  - Given preconditions and test data

steps:
  - Given initial state
  - When user performs action
  - Then expected outcome occurs
  - And additional validations

teardown:
  - Clean up test artifacts
  - Reset application state

validation:
  screenshots: true
  logs: true
  performance: true
```

### Gherkin Keywords

- **Given** - Set up preconditions
- **When** - Perform actions
- **Then** - Assert expected outcomes
- **And/But** - Chain multiple steps

## App Intent Integration

For best results, expose your app's key functionality via App Intents:

```swift
import AppIntents

@available(macOS 13.0, *)
struct OpenDocumentIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Document"

    @Parameter(title: "File Path")
    var filePath: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let documentID = try await DocumentManager.shared.open(path: filePath)
        return .result(value: documentID)
    }
}
```

Create an `AppIntents.json` manifest in your app's Resources:

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

## CI/CD Integration

### GitHub Actions

```yaml
name: Regression Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-15

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

## Configuration

### API Key Setup

**macOS App:**
- Settings → AI Configuration → Enter your Anthropic API key
- Stored securely in macOS Keychain

**CLI Tool:**
```bash
export PRUEBAS_AI_API_KEY="your-api-key"
```

Or pass directly:
```bash
scenario-runner generate --ai-api-key "your-api-key" ...
```

### Target App Configuration

Specify your app's bundle identifier:

```bash
scenario-runner run --app "com.yourcompany.YourApp"
```

## Project Structure

```
SwiftPruebas/
├── SwiftPruebas/              # macOS app
│   ├── Views/                 # SwiftUI views
│   ├── Models/                # Data models
│   └── Services/              # Business logic
├── scenario-runner/           # CLI tool
│   ├── Commands/              # CLI commands
│   └── Utilities/             # Helper utilities
├── SwiftPruebasCore/          # Shared framework
│   ├── ScenarioParser.swift
│   ├── AITestGenerator.swift
│   └── TestRunner.swift
├── Tests/
│   ├── Scenarios/             # YAML test scenarios
│   ├── Generated/             # AI-generated tests
│   └── Fixtures/              # Test data
└── Docs/                      # Documentation
```

## Documentation

- [Architecture Overview](Docs/AI_POWERED_TESTING_ARCHITECTURE.md) - Complete system architecture
- [Scenario Format Guide](Docs/SCENARIO_FORMAT.md) - YAML specification (coming soon)
- [App Intent Integration](Docs/APP_INTENT_INTEGRATION.md) - Integration guide (coming soon)
- [API Reference](Docs/API_REFERENCE.md) - API documentation (coming soon)

## Development Roadmap

### Phase 1: Core Infrastructure (Current)
- YAML scenario parser
- AI test generator (Claude API)
- App Intent discovery
- XCUITest code generation
- Basic CLI runner

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
- Self-healing tests
- Test suggestion engine
- Scenario generation from user stories

### Phase 5: Ecosystem
- VS Code extension
- Xcode extension
- Web dashboard
- Public scenario library

## Requirements

- macOS 13.0+ (for App Intent support)
- Xcode 15.0+
- Swift 6.0+
- Anthropic API key (for AI test generation)

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

[Add your license here]

## Credits

Built with:
- [Claude Sonnet 4.5](https://www.anthropic.com/claude) - AI test generation
- [Swift ArgumentParser](https://github.com/apple/swift-argument-parser) - CLI interface
- [XCTest](https://developer.apple.com/documentation/xctest) - Test execution framework

## Support

For questions, issues, or feature requests:
- Open an issue on GitHub
- Check the [documentation](Docs/)
- Review example scenarios in `Tests/Scenarios/`

---

**SwiftPruebas** - Write tests in English, let AI handle the code.
