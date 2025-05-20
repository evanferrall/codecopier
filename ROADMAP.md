Below is a single-track, parallel-friendly roadmap that lets ten developers refactor the codebase at once without merge-headaches. Every task has a clear branch name, owned module, agreed-upon class/actor names, and a "definition-of-done" (DoD). I’ve folded in the latest Apple guidance on Swift Concurrency, SwiftData, glass-style materials, list performance, and accent-colour customisation. Citations follow each section.

0 · Target product slice (what ships)
Must ship in v1Nice-to-have (v1.1+)
• Token dashboard with live counts
• Fast “Copy + Split + TOC” aggregation
• Live line-count & heat-map bars
• macOS-native look + 1 branded accent colour + glassmorphism
• Smooth expand/collapse + selection animations
• Single SwiftData store (no SQLite)
• Zero-stall UI while scanning/aggregating• Per-folder stats heat-map
• History viewer (SwiftData history API)
• Plug-in API for custom aggregators

1 · High-level architecture
```swift
┌── AppShellView (SwiftUI) ──┐
│                            │
│   ┌─────────────┐          │
│   │ DashboardUI │ ◀─────┐  │
│   └─────────────┘       │  │
│         ▲               │  │
│         │ Combine/      │  │ Observation
│         │  async let    │  │
│   ┌─────────────┐       │  │
│   │  ViewModel  │────┐  │  │
│   └─────────────┘    │  │  │
│        ▲  ▲          │  │  │
│        │  │ async    │  │  │
│   ╔══════════════╗   │  │  │
│   ║  Services     ║   │  │  │
│   ║───────────────║   │  │  │
│   ║• FileScanner  ║───┘  │  │
│   ║• Aggregator   ║──────┘  │
│   ║• TokenService ║───┐     │
│   ╚═══════════════╝   │     │
│        ▲   ▲ SwiftData│     │
│        │   └──────────┘     │
│   ┌─────────────┐           │
│   │  DataStore  │ (actor)   │
└───┴─────────────┴───────────┘
```
UI layer ⇒ pure SwiftUI/Observation, glass materials (.glassBackgroundEffect) and a single BrandColors.accent published via .accentColor()

Services layer ⇒ stateless actors using structured concurrency / TaskGroup patterns (no custom semaphores) in line with WWDC guidance.

Data layer ⇒ one AppDataStore actor that wraps SwiftData ModelContext with background task isolation (no cross-context mutations).

Performance guard-rails: Lists use .tableStyle(.inset) + @State var items: [Identifiable] streamed page-wise to avoid macOS list thrash.

2 · Branch plan (10 parallel streams)
BranchOwnerScopeKey types & filenamesDoD
feature/datastoreDev 1Implement SwiftData schema, migrations, AppDataStore actorModels.swift, AppDataStore.swiftCRUD passes unit tests; background writes use await dataStore.save() without Main-Actor hops
feature/filescannerDev 2Replace DirectoryScanner + FileDiscoverer with FileScannerService actor using AsyncStream<FileMeta> + TaskGroup throttlingFileScannerService.swiftScans 10k files < 2 s; 0 dropped updates
feature/aggregatorDev 3Refine Aggregator to stream chunks; inject into view-model via protocolAggregator.swift, AggregationAPI.swiftCopy 20 MB text in < 150 ms; unit-split tests green
feature/token-serviceDev 4Wrap Tiktoken in TokenService actor (parallel batching) + progress Combine publisherTokenService.swift100 kB source → tokens in < 80 ms; TSAN-clean
feature/navigation-uiDev 5Re-compose NavigationSplitView & sidebar; adopt .animation(.snappy) with matchedGeometryEffectNavigationShell.swift, SidebarView.swiftExpand/collapse FPS > 120 on M1
feature/glass-themeDev 6Central BrandColors + glass materials, bring .glassBackgroundEffect(in: .window) to all toolbars/footersTheme.swift, modifiersColor pick enumerates NSColorPanel; passes contrast check
feature/list-perfDev 7Virtualised file list: lazy paging, diff-aware updates, sectioned data sourceFileTableView.swift, FileDataSource.swiftScroll 5 k rows < 4 ms CPU per frame
feature/animation-kitDev 8Build reusable SmoothToggle + SlideFade transitions, unify durations/easingsAnimations.swiftAll interactive toggles share .easeOut(duration:0.25); verified via snapshot tests
feature/status-toastDev 9Extract ToastHost, StatusBarView into overlay layer with OSLog signpostsNotifications.swiftToast appears < 70 ms after publisher emit; no memory leaks
infra/ci-docsDev 10GitHub Actions: lint, test, DocC; write CONTRIBUTING.md, Architecture.md.github/, docsPR must pass “Swift Lint + 90 % unit cov” gate

Merge convention: each branch rebases onto main nightly, uses prefix(scope): summary commit style (Conventional Commits).

3 · Concrete refactor tasks (per layer)
3.1 UI cleanup
Replace manual .background(.ultraThinMaterial) wrappers with GlassPane view modifier that applies system glass in one line (keeps shader cost low).

Move all @State var show* toggles into a @Bindable struct UIOptions kept in AppEnvironment for previewability.

Swap List for Table on macOS 15 to gain column resizing and built-in virtualization; group by folder path for huge trees.

Add withAnimation(.interactiveSpring) to selection + expansion; for heavy layout shifts use .transaction { $0.disablesAnimations = sizeBig }.

3.2 Concurrency & data flow
File scans — single scan(root:) async -> AsyncStream<FileMeta>; view-model observes with for await. No semaphores; instead, TaskGroup with maxConcurrent = hardwareConcurrency.

SwiftData — @Model FileCacheEntry keyed by SHA-timestamp; one background context actor. Use SwiftData history API to purge old entries nightly.

Token counting — token service actor batches requests; publishes @Published currentTokenCount. View binds to ProgressView.

3.3 Performance guards
De-couple ViewModel from arrays > 5 k by feeding ListState pages of 300 items using .prefetch(offset:).

Off-main thread SHA/line counting; write to SwiftData in background, then publish new snapshot through Observation.

Use OSSignposter in each actor to profile; integrate “points of interest” signposts for Instruments.

4 · Standard names & hooks
ConcernProtocol / TypeModule
Scanningprotocol FileScanning { func scan(url: URL) -> AsyncStream<FileMeta> }Services
Aggregationprotocol SourceAggregator { func aggregate(_: [FileInfo], split:Int, includeTOC:Bool) async throws -> [String] }Services
Token countactor TokenServiceServices
Data storeactor AppDataStore + @Model FileCacheEntryData
Themestruct BrandColors + GlassPane modifierUI
View model@Observable class DashboardViewModelFeatures/Dashboard

Each service is injected via an AppEnvironment value type, which previews can swap with mocks.

5 · CI & quality gates
GitHub Actions: swift test, swiftlint --strict, docc preview --diagnostics.

Danger-Swift runs on PR to check module boundaries (no import UI inside Services).

Automatic Instruments run on nightly to capture frame-times > 16 ms.

6 · Colour & glass spec
Accent colour constant BrandColors.accent = Color(red:0.11, green:0.46, blue:0.98) (system-blue variant for recognisability).

Apply .accentColor(BrandColors.accent) in AppShellView root; override allowed by System Preferences.

Replace per-view .background(.ultraThinMaterial) with .glassBackgroundEffect(in: .window, displayMode: .always) for toolbars, status bar, token dashboard.

7 · Next steps
Create branches & stub modules (infra/ci-docs owns).

Each owner stubs protocols + empty tests, pushes, opens draft PR.

Daily 10-min stand-up to surface cross-branch type changes; any shared type edits must be made on feature/shared-api and merged early.

After two sprints, feature freeze → merge gate (CI green + 0 conflicts).

With this blueprint everyone can code in parallel, confident that their pieces slot together cleanly. Let me know if you’d like deeper task sizing or Figma references, and I’ll break them down
