# Contributing

Thank you for considering a contribution to CodeCopier! This project follows a lightweight GitHub flow with a preference for small, focused pull requests.

## Development Setup
1. Install Xcode 15 or later.
2. Clone the repository and run `swift build` to fetch dependencies.
3. Run `swiftlint` before committing. A GitHub Action enforces linting and unit tests on every pull request.

## Pull Request Process
- Fork the repository and create a feature branch.
- Include relevant unit tests for any new code.
- Ensure `swift test --enable-code-coverage` succeeds locally.
- Submit the pull request. CI will fail if SwiftLint warnings are present or code coverage drops below 90%.

We appreciate all feedback and fixes! For larger changes, please open an issue first to discuss the approach.
