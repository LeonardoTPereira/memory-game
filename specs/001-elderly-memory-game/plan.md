# Implementation Plan: Elderly Brain Training Memory Matching Game

**Branch**: `001-elderly-memory-game` | **Date**: 2026-05-03 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-elderly-memory-game/spec.md`

## Summary

A brain-training memory matching card game for elderly players built in Godot 4 with
GDScript. Players choose a difficulty (Easy 4×4, Medium 6×6, Hard 8×8), flip pairs of
vintage-themed cards (drawn randomly from a pool of 50), receive immediate audio-visual
feedback per guess, optionally use a hint after 10 consecutive wrong guesses, and see a
final score when all pairs are matched. The implementation follows strict composition-first
node architecture, signal-driven decoupling, full static typing, and TDD with GdUnit4 at
100% game-logic coverage.

---

## Technical Context

**Language/Version**: GDScript (Godot 4.3+)
**Primary Dependencies**: GdUnit4 addon (v4.x) — test framework; Godot 4 built-in audio,
particles, animation, and input subsystems; no third-party runtime dependencies.
**Storage**: N/A — no persistence; score is ephemeral per session.
**Testing**: GdUnit4 (unit + integration + UI Page Object tests), run via Godot editor test
runner and CI headless export.
**Target Platform**: Desktop (Windows/macOS/Linux primary); web export is out of scope
for this version.
**Project Type**: Desktop game application.
**Performance Goals**: Stable 60 fps during gameplay; board populates within 3 seconds of
difficulty selection; match-outcome feedback visible within 200 ms of second card reveal.
**Constraints**: 48×48 px minimum tap/click target; ≥24 px font at 1080p; offline-only;
no leaderboard or persistence.
**Scale/Scope**: 50 card-pair images, 3 difficulty levels, 7 GDScript components,
~6 GdUnit4 test suites.

---

## Constitution Check

*GATE: Pre-Phase-0 check. Re-evaluated after Phase 1 design — both pass.*

### ✅ Composition-First Node Architecture

Every gameplay concern is an independent node or resource:

| Component | Node/Resource | Responsibility |
| --------- | ------------- | -------------- |
| `Card` | Node (scene) | Flip state, textures, focus highlight, emit signals |
| `BoardManager` | Node (script component) | Grid generation, pair shuffle, match validation, state |
| `CardPool` | Resource (script) | Load and randomly sample pairs from the 50-pair pool |
| `GameSession` | Node (scene root script) | Orchestrate signals, delegate to sub-components |
| `HintController` | Node (child of GameSession) | Wrong-guess count, hint eligibility, highlight trigger |
| `InputNavigator` | Node (child of GameSession) | Keyboard/gamepad focus, grid navigation |
| `ScoreCalculator` | Plain GDScript class (no Node) | Pure formula: `floor((pairs / max(1, guesses)) * 1000)` |

No component inherits game-logic behaviour from another. Inheritance is used only for
Godot built-in base classes (`Control`, `Node2D`, `Resource`), which are stable
framework abstractions.

### ✅ Signal-Driven Decoupling

All cross-component events use typed signals. No `get_node("../../")` calls cross
component boundaries. Signal contracts:

| Signal | Emitter | Payload types | Consumers |
| ------ | ------- | ------------- | --------- |
| `card_selected(card: Card)` | Card | `Card` | BoardManager |
| `pair_matched(pair_id: int)` | BoardManager | `int` | GameSession, UI |
| `wrong_guess_made(wrong_count: int)` | BoardManager | `int` | HintController, UI |
| `game_finished(final_score: int)` | GameSession | `int` | ScoreOverlay, MainMenu |
| `hint_requested()` | HintController | — | BoardManager |
| `hint_eligibility_changed(enabled: bool)` | HintController | `bool` | UI HintButton |

Direct method calls are used only *within* a single component (e.g., `Card` calling its
own `AnimationPlayer` methods) where coupling is intentional and peer-reviewed.

### ✅ Static Typing and SOLID Design

- All variables, function parameters, return types, and signal payloads carry explicit
  GDScript type annotations.
- **Single Responsibility**: one script per concern (see table above); `ScoreCalculator`
  is a pure-logic class with no UI references.
- **Open/Closed**: `DifficultyPreset` resource allows adding new difficulties without
  changing `BoardManager` logic.
- **Liskov / Interface Segregation**: not applicable to GDScript's duck-typed scene
  composition, but component interfaces are kept narrow by design.
- **Dependency Inversion**: `BoardManager` receives a `CardPool` resource via `@export`
  rather than constructing it internally; `GameSession` receives difficulty via signal,
  not by direct reference.

### ✅ Testing and Coverage Enforcement

Test-first order:

1. Write failing GdUnit4 tests for `ScoreCalculator` (zero guesses, perfect game,
   fractional result).
2. Write failing tests for `CardPool` (correct count, no repetition, different seeds).
3. Write failing integration tests for `BoardManager` (shuffle, match validation, state
   transitions).
4. Write failing UI Page Object tests for Hint button enable/disable and ScoreOverlay.
5. Implement only after each test fails for the right reason.

100% line + branch coverage is required for: `ScoreCalculator`, `CardPool`,
`BoardManager`, `HintController`, `Card` (state machine), `GameSession` logic methods.

Page Object classes: `PoHintButton` and `PoScoreOverlay` (in `tests/memory_game/page_objects/`).

### ✅ Static Analysis and Runtime Quality Gates

- Godot 4 built-in static analysis enabled (project settings → script editor warnings
  all set to error).
- CI headless test run (`godot --headless --run-tests`) MUST exit 0.
- Debug build emits `print_rich` logs on: card flip, match evaluation outcome, hint
  trigger, score calculation, scene transitions.
- No `@warning_ignore` annotations without an inline comment explaining justification.

---

## Project Structure

### Documentation (this feature)

```text
specs/001-elderly-memory-game/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

*No `contracts/` directory: this is a self-contained desktop game with no external
interfaces (no API, CLI, or shared schema).*

### Source Code (repository root — Godot 4 project)

```text
scenes/
└── memory_game/
    ├── main_menu.tscn          # Difficulty selection screen
    ├── game_board.tscn         # Root game scene (GameSession node)
    ├── card.tscn               # Single card (Button + textures + AnimationPlayer)
    └── score_overlay.tscn      # End-of-game score popup (CanvasLayer)

scripts/
└── memory_game/
    ├── card.gd                 # class_name Card
    ├── board_manager.gd        # class_name BoardManager
    ├── card_pool.gd            # class_name CardPool
    ├── card_data.gd            # class_name CardData  (Resource subclass)
    ├── difficulty_preset.gd    # class_name DifficultyPreset  (Resource subclass)
    ├── game_session.gd         # class_name GameSession
    ├── hint_controller.gd      # class_name HintController
    ├── input_navigator.gd      # class_name InputNavigator
    └── score_calculator.gd     # class_name ScoreCalculator  (plain class, no Node)

assets/
└── memory_game/
    ├── card_fronts/            # card_001.png … card_050.png (50 images, 1940s–1980s)
    ├── card_back.png
    ├── audio/
    │   ├── correct.ogg
    │   ├── wrong.ogg
    │   └── background_theme.ogg
    └── particles/
        ├── correct_particles.tscn
        └── wrong_particles.tscn

tests/
└── memory_game/
    ├── test_score_calculator.gd
    ├── test_card_pool.gd
    ├── test_board_manager.gd
    ├── test_hint_controller.gd
    ├── test_card_state.gd
    ├── page_objects/
    │   ├── po_hint_button.gd
    │   └── po_score_overlay.gd
    └── test_ui_hint_and_score.gd
```

**Structure Decision**: Godot 4 project-root layout with `scenes/`, `scripts/`,
`assets/`, and `tests/` top-level folders mirroring each other by feature sub-path
(`memory_game/`). All gameplay scripts use `class_name` declarations so GdUnit4 can
instantiate them directly without scene context where possible.

---

## Component Design

### Scene Node Trees

#### `main_menu.tscn`

```
MainMenu (Control)
└── VBoxContainer
    ├── TitleLabel (Label)
    ├── EasyButton (Button)       # "Easy – 4×4 · 8 pairs"
    ├── MediumButton (Button)     # "Medium – 6×6 · 18 pairs"
    └── HardButton (Button)       # "Hard – 8×8 · 32 pairs"
```

*Script*: `MainMenu` (inline, lightweight) — emits `difficulty_selected(preset: DifficultyPreset)` signal; loads `game_board.tscn`.

#### `game_board.tscn`

```
GameBoard (Control)  ← GameSession script attached
├── BoardManager (Node)
├── HintController (Node)
├── InputNavigator (Node)
├── VBoxContainer
│   ├── TopBar (HBoxContainer)
│   │   ├── ScoreLabel (Label)           %ScoreLabel
│   │   ├── GuessCountLabel (Label)      %GuessCountLabel
│   │   └── HintButton (Button)          %HintButton
│   └── GridContainer (GridContainer)    %GridContainer
├── FeedbackLayer (CanvasLayer)
│   ├── FeedbackLabel (Label)            # "CORRETO" / "ERRADO"
│   └── ParticleSpawner (Node2D)
└── ScoreOverlay (CanvasLayer)           # hidden until game end
```

#### `card.tscn`

```
Card (Button)  ← Card script attached
├── BackFace (TextureRect)
├── FrontFace (TextureRect)
├── FocusHighlight (ColorRect)   # visible only when focused via keyboard/gamepad
├── HintHighlight (ColorRect)    # visible only during hint
└── AnimationPlayer
```

### Script Responsibilities

#### `card.gd` — `class_name Card`

```gdscript
signal card_selected(card: Card)

enum FaceState { FACE_DOWN, FACE_UP, MATCHED }
enum FocusState { UNFOCUSED, FOCUSED, HINT_HIGHLIGHTED }

@export var card_data: CardData
var face_state: FaceState = FaceState.FACE_DOWN
var focus_state: FocusState = FocusState.UNFOCUSED

func flip_face_up() -> void   # plays AnimationPlayer "flip_up"
func flip_face_down() -> void # plays AnimationPlayer "flip_down"
func set_matched() -> void    # locks face-up, clears interactivity
func set_focus(state: FocusState) -> void
```

#### `board_manager.gd` — `class_name BoardManager`

```gdscript
signal pair_matched(pair_id: int)
signal wrong_guess_made(wrong_count: int)
signal all_pairs_matched()

@export var card_pool: CardPool
@export var card_scene: PackedScene

func setup(preset: DifficultyPreset, grid: GridContainer) -> void
func on_card_selected(card: Card) -> void   # handles evaluation window
func _evaluate_pair() -> void               # private; emits pair_matched or wrong_guess_made
func reset() -> void
```

#### `card_pool.gd` — `class_name CardPool`

```gdscript
@export var all_cards: Array[CardData]  # all 50 CardData resources

func sample_pairs(count: int, rng: RandomNumberGenerator) -> Array[CardData]
# Returns `count` unique CardData items, no repetition. Deterministic given same rng seed.
```

#### `score_calculator.gd` — `class_name ScoreCalculator`

```gdscript
# Pure class — no Node, no scene dependency.
static func calculate(pairs_found: int, total_guesses: int) -> int:
    return floori((float(pairs_found) / maxf(1.0, float(total_guesses))) * 1000.0)
```

#### `hint_controller.gd` — `class_name HintController`

```gdscript
signal hint_eligibility_changed(enabled: bool)
signal hint_requested()

const WRONG_GUESSES_REQUIRED: int = 10

var _wrong_since_last_hint: int = 0

func on_wrong_guess(wrong_count: int) -> void
func request_hint() -> void   # called by HintButton.pressed
func reset() -> void
```

#### `input_navigator.gd` — `class_name InputNavigator`

```gdscript
@export var grid_columns: int

func set_focusable_cards(cards: Array[Card]) -> void
func _unhandled_input(event: InputEvent) -> void  # handles ui_left/right/up/down/accept
func _move_focus(delta: Vector2i) -> void
```

#### `game_session.gd` — `class_name GameSession`

```gdscript
signal game_finished(final_score: int)

@onready var _board_manager: BoardManager = %BoardManager
@onready var _hint_controller: HintController = %HintController
@onready var _input_navigator: InputNavigator = %InputNavigator
@onready var _score_label: Label = %ScoreLabel
@onready var _guess_label: Label = %GuessCountLabel
@onready var _hint_button: Button = %HintButton
@onready var _grid: GridContainer = %GridContainer

func start(preset: DifficultyPreset) -> void
func _on_pair_matched(pair_id: int) -> void
func _on_wrong_guess_made(wrong_count: int) -> void
func _on_all_pairs_matched() -> void  # computes score, shows overlay, emits game_finished
func _on_hint_eligibility_changed(enabled: bool) -> void
```

---

## Signal Flow Diagram

```
[Card] --card_selected(card)--> [BoardManager]
         |
         +-- match? --> [BoardManager] --pair_matched(id)--> [GameSession]
         |                                                        |
         |                                               updates ScoreLabel
         |                                               checks all_pairs_matched
         |
         +-- no match --> [BoardManager] --wrong_guess_made(n)--> [HintController]
                                                                        |
                                                       hint_eligibility_changed(bool)--> [UI HintButton]
                                                                        |
                                                              [HintButton.pressed]
                                                                        |
                                                              hint_requested()--> [BoardManager._apply_hint()]

[BoardManager] --all_pairs_matched()--> [GameSession] --game_finished(score)--> [ScoreOverlay]
                                                                                       |
                                                                            player confirms --> MainMenu
```

---

## Testing Plan (TDD — tests fail first)

### Unit: `test_score_calculator.gd`

| Test | Input | Expected |
| ---- | ----- | -------- |
| perfect game | pairs=8, guesses=8 | 1000 |
| zero guesses guard | pairs=0, guesses=0 | 0 |
| below perfect | pairs=8, guesses=16 | 500 |
| fractional floors | pairs=1, guesses=3 | 333 |

### Unit: `test_card_pool.gd`

| Test | Scenario |
| ---- | -------- |
| correct count | `sample_pairs(8)` returns exactly 8 `CardData` items |
| no repetition | all returned items have distinct `id` values |
| full pool | `sample_pairs(50)` returns all 50 items |
| overflow guard | `sample_pairs(51)` raises an error or returns 50 |
| determinism | same `rng` seed produces same selection |

### Integration: `test_board_manager.gd`

| Test | Scenario |
| ---- | -------- |
| grid population | `setup(easy_preset, grid)` creates 16 Card nodes |
| match detection | selecting the same `CardData.id` twice emits `pair_matched` |
| mismatch detection | selecting different ids emits `wrong_guess_made` |
| input blocking | third card selection during evaluation window is ignored |
| reset | `reset()` clears board and counters |
| game completion | matching all pairs emits `all_pairs_matched` |

### Unit: `test_hint_controller.gd`

| Test | Scenario |
| ---- | -------- |
| not eligible at 9 | `hint_eligibility_changed(false)` at wrong count 9 |
| eligible at 10 | `hint_eligibility_changed(true)` at wrong count 10 |
| reset on hint use | counter resets to 0 after `request_hint()` |

### UI Page Object: `test_ui_hint_and_score.gd`

Uses `PoHintButton` and `PoScoreOverlay` page objects to assert:

- Hint button is disabled at game start.
- Hint button becomes enabled after 10 wrong guesses (driven via `BoardManager`
  mock signals, not real card interactions).
- Score overlay displays the correct formula result after `game_finished` signal.
- Score overlay confirm button returns to MainMenu scene.

---

## Performance and Accessibility

| Requirement | Implementation |
| ----------- | -------------- |
| 60 fps | Particle scenes kept lightweight; card animations use `Tween`, not `AnimationPlayer` with tracks, for simple transforms |
| Board load < 3s | All 50 card textures `preload()`-ed in `CardPool`; only selected subset instantiated per game |
| Feedback < 200ms | Particle and audio nodes parented in scene tree — no runtime `add_child` |
| 48×48 px targets | `Card` `Button` minimum size set in Theme; `custom_minimum_size = Vector2(48, 48)` |
| ≥24px font | Project Theme defines `Label` and `Button` font sizes; all sizes in a single `theme.tres` |
| Scalable grid | `GridContainer` inside `AspectRatioContainer` with expand fill; card minimum sizes scale via theme |
| Keyboard/gamepad | `InputNavigator` handles `ui_left/right/up/down/accept`; `Card.set_focus()` drives `FocusHighlight` |
| Colour-independent feedback | "CORRETO"/"ERRADO" text always present alongside colour cues; hint highlight uses shape, not colour alone |

### Godot Input Map Actions (project settings)

| Action | Keyboard | Gamepad |
| ------ | -------- | ------- |
| `ui_left` | Arrow Left | D-Pad Left / Left Stick Left |
| `ui_right` | Arrow Right | D-Pad Right / Left Stick Right |
| `ui_up` | Arrow Up | D-Pad Up / Left Stick Up |
| `ui_down` | Arrow Down | D-Pad Down / Left Stick Down |
| `ui_accept` | Space, Enter | Button South (A/Cross) |

---

## Complexity Tracking

*No constitution violations. No complexity exceptions required.*
