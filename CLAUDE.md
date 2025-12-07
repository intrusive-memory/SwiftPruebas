# Claude Instructions for SwiftPruebas

## Project Overview

SwiftPruebas is an AI-powered testing library for macOS and iOS applications that enables developers to write tests in human-readable YAML/Gherkin format and automatically generates XCUITest code using AI.

**Platforms**: macOS 26.0+ / iOS 26.0+

## ⚠️ CRITICAL: Platform Version Enforcement

**This project ONLY supports iOS 26.0+ and macOS 26.0+. NEVER add code that supports older platforms.**

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

## Architecture Context

This project consists of three main components:

1. **SwiftPruebas macOS App** - Visual scenario editor and test runner
2. **scenario-runner CLI** - Headless test runner for CI/CD pipelines
3. **SwiftPruebasCore Framework** - Shared testing infrastructure

## Code Style and Conventions

### Swift Style
- Use Swift 6.0+ with strict concurrency enabled
- Prefer async/await over completion handlers
- Use structured concurrency (TaskGroup, async let) where appropriate
- Follow Swift API Design Guidelines
- Use descriptive variable and function names

### Architecture Patterns
- SwiftUI for UI components
- SwiftData for persistence in the macOS app
- Protocol-oriented design for extensibility
- Dependency injection for testability

### Testing Approach
- Write tests that use App Intents for business logic when possible
- Use XCUITest only for UI validation
- Generate screenshot evidence at critical test points
- Include comprehensive error handling with descriptive messages

## Key Technical Decisions

### AI Test Generation
- Primary AI model: Claude Sonnet 4.5 via Anthropic API
- Fallback support for compatible LLMs
- API key stored securely in Keychain (macOS) or environment variables (CLI)
- Prompt engineering focuses on generating stable, maintainable XCUITest code

### App Intent Integration
- Target apps expose testable functionality via App Intents
- Discovery via AppIntents.json manifest in app bundle
- Prefer App Intents over UI automation for speed and stability
- Graceful fallback to UI automation when intents unavailable

### Scenario Format
- YAML-based with Gherkin syntax (Given/When/Then)
- Support for setup/teardown, tags, timeouts, and validation options
- Human-readable and version-control friendly
- Extensible metadata for AI context

## File Organization

```
SwiftPruebas/
├── SwiftPruebas/              # macOS app target
│   ├── Views/                 # SwiftUI views
│   ├── Models/                # Data models with SwiftData
│   └── Services/              # Business logic services
├── scenario-runner/           # CLI tool target
│   ├── Commands/              # ArgumentParser commands
│   └── Utilities/             # Helper utilities
├── SwiftPruebasCore/          # Shared framework
│   ├── ScenarioParser.swift
│   ├── AITestGenerator.swift
│   ├── AppIntentDiscovery.swift
│   └── TestRunner.swift
├── Tests/
│   ├── Scenarios/             # YAML test scenarios
│   ├── Generated/             # AI-generated test code
│   └── Fixtures/              # Test data files
└── Docs/                      # Documentation
```

## Development Guidelines

### When Adding Features

1. **Read existing code first** - Understand the current implementation before making changes
2. **Maintain consistency** - Follow existing patterns and conventions
3. **Update tests** - Add/update tests for new functionality
4. **Document changes** - Update relevant documentation files
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

- Never commit API keys to version control
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

## Common Tasks

### Adding a New Scenario
1. Create YAML file in `Tests/Scenarios/`
2. Validate syntax: `scenario-runner validate --scenarios-dir Tests/Scenarios`
3. Generate test: `scenario-runner generate --scenario Tests/Scenarios/your-scenario.yaml`
4. Review generated code in `Tests/Generated/`
5. Run test: `scenario-runner run --scenario Tests/Scenarios/your-scenario.yaml`

### Implementing a New App Intent
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

## References

For detailed information, refer to:
- `Docs/AI_POWERED_TESTING_ARCHITECTURE.md` - Complete architecture documentation
- `Docs/SCENARIO_FORMAT.md` - Scenario YAML specification (when created)
- `Docs/APP_INTENT_INTEGRATION.md` - App Intent integration guide (when created)
- `Docs/API_REFERENCE.md` - API documentation (when created)

## Development Roadmap

Current phase: **Phase 1 - Core Infrastructure**

Focus areas:
- YAML scenario parser implementation
- Claude API integration for test generation
- App Intent discovery system
- XCUITest code generation engine
- Basic CLI runner functionality

See `Docs/AI_POWERED_TESTING_ARCHITECTURE.md` for complete roadmap.
