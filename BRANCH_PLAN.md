# Branch Plan for Parallel Refactor

This document expands on step 2 of `ROADMAP.md`. Each branch name matches the scope of a
module or feature so multiple developers can work in parallel without conflicts.

| Branch | Owner | Scope / Key Files | Definition of Done |
|-------|-------|-------------------|--------------------|
| `feature/datastore` | Dev 1 | `Models.swift`, `AppDataStore.swift` | CRUD tests pass; async writes use `await dataStore.save()` off the main actor. |
| `feature/filescanner` | Dev 2 | `FileScannerService.swift` | Scans 10k files under 2 s with zero dropped updates. |
| `feature/aggregator` | Dev 3 | `Aggregator.swift`, `AggregationAPI.swift` | Copy 20 MB text in <150 ms; unit-split tests green. |
| `feature/token-service` | Dev 4 | `TokenService.swift` | 100 kB source → tokens in <80 ms; TSAN clean. |
| `feature/navigation-ui` | Dev 5 | `NavigationShell.swift`, `SidebarView.swift` | Expand/collapse FPS >120 on M1. |
| `feature/glass-theme` | Dev 6 | `Theme.swift`, `modifiers` | Glass background everywhere, passes contrast check. |
| `feature/list-perf` | Dev 7 | `FileTableView.swift`, `FileDataSource.swift` | Scroll 5k rows <4 ms CPU per frame. |
| `feature/animation-kit` | Dev 8 | `Animations.swift` | All toggles use shared easing; snapshot tests pass. |
| `feature/status-toast` | Dev 9 | `Notifications.swift` | Toast appears <70 ms after emit; no leaks. |
| `infra/ci-docs` | Dev 10 | `.github/`, `docs` | CI runs lint & tests with ≥90% coverage. |

All branches follow the merge convention described in `ROADMAP.md` and rebase onto `main` nightly.
