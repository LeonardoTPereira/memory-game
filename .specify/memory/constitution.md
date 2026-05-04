<!--
Sync Impact Report
- Version change: 1.0.0 -> 2.0.0
- Modified principles:
	- I. Deterministic Core Gameplay -> I. Composition-First Node Architecture
	- II. Scene and Script Modularity -> II. Signal-Driven Decoupled Communication
	- III. Test-First Rule Changes (NON-NEGOTIABLE) -> III. Static Typing and SOLID Design
	- IV. Accessibility and UX Clarity -> IV. Testing and Coverage Enforcement (NON-NEGOTIABLE)
	- V. Performance and Runtime Observability -> V. Static Analysis and Runtime Quality Gates
- Added sections:
	- Language and Architecture Standards
	- Delivery Workflow and Review Gates
- Removed sections:
	- Technical Constraints
	- Workflow and Quality Gates
- Templates requiring updates:
	- ✅ updated: .specify/templates/plan-template.md
	- ✅ updated: .specify/templates/spec-template.md
	- ✅ updated: .specify/templates/tasks-template.md
	- ✅ verified (not present): .specify/templates/commands/*.md
	- ✅ reviewed: .github/copilot-instructions.md
- Follow-up TODOs:
	- None
-->

# Memory Game Constitution

## Core Principles

### I. Composition-First Node Architecture

Gameplay systems MUST prefer composition over inheritance. Nodes MUST be treated as
behavioral components with explicit responsibilities and clear boundaries. Deep
inheritance trees for feature behavior MUST NOT be introduced when composition can
achieve the same result. Teams SHOULD keep composition units small and reusable, and
MAY introduce inheritance only for stable framework-level abstractions that cannot be
represented cleanly through composition. Rationale: composition improves flexibility,
testability, and long-term maintainability in Godot projects.

### II. Signal-Driven Decoupled Communication

Cross-component communication MUST use signals for decoupling. Scripts MUST NOT depend
on fragile hard-coded node path traversal for unrelated subsystem interactions. Signals
SHOULD be typed and documented with payload semantics so callers and listeners remain
independent. Direct method calls MAY be used for tightly scoped internal collaborators
inside a single component boundary where coupling is intentional and reviewed.
Rationale: decoupled signaling reduces cascading breakage and enables safer iteration.

### III. Static Typing and SOLID Design

GDScript code MUST use static typing everywhere practical, including variables,
function parameters, returns, and signal payloads. Every gameplay script MUST follow
SOLID principles, with explicit focus on single responsibility and dependency
inversion for testable rule logic. New code MUST NOT introduce untyped gameplay logic
or god-objects that mix unrelated concerns. Teams SHOULD prefer explicit interfaces,
and MAY use adapters/facades to keep dependencies narrow. Rationale: static typing and
SOLID design make intent clearer, catch defects earlier, and protect maintainability.

### IV. Testing and Coverage Enforcement (NON-NEGOTIABLE)

Game logic MUST have 100% automated test coverage for lines and branches relevant to
rules, scoring, progression, and persistence behavior. Rule changes MUST begin with
failing tests, and bug fixes MUST include regression tests. UI automation MUST use the
Page Object pattern to keep selectors and interaction flows maintainable. Test suites
MUST NOT be merged with known failing tests for covered logic. Teams SHOULD keep tests
small and deterministic, and MAY use test doubles for engine boundaries.
Rationale: strict coverage and structured UI tests keep behavior reliable as scope grows.

### V. Static Analysis and Runtime Quality Gates

All code MUST pass static analysis before merge. Build or CI pipelines MUST fail when
configured analysis, typing, or lint gates fail. Gameplay features SHOULD define
runtime diagnostics and logging for actionable troubleshooting, and MUST NOT suppress
critical warnings without documented justification. Teams MAY add additional quality
gates (performance budgets, load-time checks) when feature risk warrants.
Rationale: enforceable quality gates prevent regression and reduce production defects.

## Language and Architecture Standards

- The project MUST target Godot 4 and use GDScript for core gameplay systems.
- Architectural decisions MUST encode requirement levels using RFC-2119 keywords:
  MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY.
- Components SHOULD isolate engine glue from domain rules to keep game logic testable.
- Save and progression schemas MUST be versioned and migration-safe.
- Third-party dependencies MAY be introduced only with documented maintenance impact.

## Delivery Workflow and Review Gates

- Feature specs MUST include independent user scenarios and explicit constitution
  alignment criteria.
- Implementation plans MUST map design decisions to all five core principles.
- Task lists MUST include static analysis checks, coverage validation, and Page Object
  UI test updates where UI behavior changes.
- Pull requests MUST include evidence of 100% game-logic coverage and static-analysis
  pass results.
- Pull requests SHOULD include rationale when using MAY-level exceptions.

## Governance

This constitution is the highest-priority project policy for delivery decisions.
Amendments MUST include: (1) a proposed change in writing, (2) impact analysis
against active templates and workflow documents, and (3) explicit approval recorded
in repository history.

Versioning policy for this constitution uses semantic versioning:

- MAJOR for principle removals, incompatible redefinitions, or governance model changes.
- MINOR for new principle/section additions or materially expanded requirements.
- PATCH for clarifications, wording improvements, and non-semantic edits.

Compliance review expectations:

- Every implementation plan and pull request MUST pass constitution checks.
- Exceptions MUST include rationale, scope, and an expiration or cleanup task.
- Runtime development guidance in .github/copilot-instructions.md MUST remain aligned
  with this constitution.

**Version**: 2.0.0 | **Ratified**: 2026-05-03 | **Last Amended**: 2026-05-03
