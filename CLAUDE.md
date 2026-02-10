# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

For detailed project documentation, architecture, and development guidelines, see **[AGENTS.md](AGENTS.md)**.

## Quick Reference

**Project**: SwiftPruebas - AI-powered regression testing for macOS and iOS applications

**Platforms**: macOS 26.0+ / iOS 26.0+

**Key Components**:
- YAML/Gherkin test scenarios (human-readable)
- AI test generator (Claude Sonnet 4.5 → XCUITest Swift code)
- App Intent discovery and integration
- `scenario-runner` CLI for CI/CD
- SwiftPruebas macOS app (visual editor and test runner)

**Important Notes**:
- ONLY supports macOS 26.0+ and iOS 26.0+ (NEVER add code for older platforms)
- MUST be built with `xcodebuild`, NOT `swift build`
- See [AGENTS.md](AGENTS.md) for complete development workflow, architecture, test generation guidelines, and CI/CD integration patterns
