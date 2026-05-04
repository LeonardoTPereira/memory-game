# Data Model: Elderly Brain Training Memory Matching Game

**Feature**: `001-elderly-memory-game`
**Phase**: 1 — Design
**Date**: 2026-05-03

---

## Overview

All data representations are GDScript classes. Persistent storage is out of scope —
all state is in-memory for one game session.

---

## Entities

### `CardData` *(Resource)*

Represents one card image from the 50-pair pool. Each image appears exactly twice on
the board (forming a pair). Immutable during gameplay.

```gdscript
class_name CardData
extends Resource

@export var id: int               # Unique 1–50; both cards in a pair share same id
@export var display_name: String  # Human-readable label, e.g. "Vintage Car"
@export var era_category: String  # e.g. "1950s", "Animals", "Everyday Objects"
@export var front_texture: Texture2D  # preload()-ed at editor time
```

**Constraints**:
- `id` MUST be unique per logical pair (1–50).
- `front_texture` MUST be non-null; enforced by `CardPool.validate()`.
- `display_name` SHOULD be non-empty for accessibility (used as card tooltip/aria-label).

**Relationships**:
- Referenced by `CardInstance.identity`.
- Owned by `CardPool.all_cards`.

---

### `CardInstance` *(runtime value object — not a Resource)*

Represents one physical card placed on the board. Two `CardInstance` objects share the
same `CardData` (forming a matchable pair). Mutable during gameplay.

```gdscript
class_name CardInstance
# Not a Resource — instantiated by BoardManager at game start.

var identity: CardData           # immutable reference to pair definition
var board_position: Vector2i     # column, row in the grid (0-indexed)
var face_state: Card.FaceState   # FACE_DOWN | FACE_UP | MATCHED
var node: Card                   # reference to the Card scene node on the board
```

**State transitions**:

```
FACE_DOWN ──[player selects]──> FACE_UP ──[match confirmed]──> MATCHED
                                         \
                                          [no match, delay]──> FACE_DOWN
```

**Constraints**:
- `board_position` MUST be unique per game (no two cards share a cell).
- `node` MUST NOT be null after `BoardManager.setup()` completes.

---

### `DifficultyPreset` *(Resource)*

Encapsulates all configuration values for one difficulty level. Allows adding new
difficulties without changing `BoardManager` logic (Open/Closed principle).

```gdscript
class_name DifficultyPreset
extends Resource

@export var label: String          # "Easy" | "Medium" | "Hard"
@export var grid_columns: int      # 4 | 6 | 8
@export var grid_rows: int         # 4 | 6 | 8
@export var pair_count: int        # 8 | 18 | 32
```

**Derived values** (computed, not stored):
- `total_cards: int = grid_columns * grid_rows`  → 16 | 36 | 64
- `total_cards == pair_count * 2` is an invariant (enforced in `BoardManager.setup()`).

**Predefined presets** (editor assets in `assets/memory_game/presets/`):
- `easy.tres` — 4×4, 8 pairs
- `medium.tres` — 6×6, 18 pairs
- `hard.tres` — 8×8, 32 pairs

---

### `BoardState` *(runtime object managed by `BoardManager`)*

Aggregates all mutable game state for one session. Not a Resource; lives inside
`BoardManager` as private fields.

```gdscript
# Fields on BoardManager representing BoardState:

var _cards: Array[CardInstance]         # all CardInstances on board
var _pending: Array[CardInstance]       # 0 or 1 item: first card of evaluation window
var _pairs_matched: int = 0
var _total_guesses: int = 0
var _wrong_for_hint: int = 0            # resets on each hint use
var _is_evaluating: bool = false        # true while second-card evaluation + feedback
```

**Derived queries** (methods on `BoardManager`):
- `get_unmatched_pairs() -> Array[Array[CardInstance]]` — used by `HintController`.
- `is_complete() -> bool` — `_pairs_matched == preset.pair_count`.

---

### `ScoreResult` *(plain value — no class needed)*

Computed once at game end. Passed as an `int` via `game_finished(final_score: int)`.

**Formula** (from `ScoreCalculator.calculate()`):
```
final_score = floor((pairs_matched / max(1, total_guesses)) * 1000)
```

| Scenario | pairs_matched | total_guesses | final_score |
| -------- | ------------- | ------------- | ----------- |
| Perfect game | 8 | 8 | 1000 |
| 50% accuracy | 8 | 16 | 500 |
| One wrong | 8 | 9 | 888 |
| Zero guesses guard | 0 | 0 | 0 |

---

## Entity Relationship Summary

```
CardPool
 └── all_cards: Array[CardData]  (50 items, immutable)
         │
         │ sample_pairs(n)
         ▼
BoardManager
 └── _cards: Array[CardInstance]
         │  each CardInstance
         │   ├── .identity: CardData
         │   ├── .board_position: Vector2i
         │   ├── .face_state: FaceState
         │   └── .node: Card (scene node)
         │
         └── _pending: Array[CardInstance]  (0..1)

DifficultyPreset ──(@export)──> BoardManager.setup()

GameSession
 ├── _pairs_matched + _total_guesses ──> ScoreCalculator.calculate() ──> int (final_score)
 └── game_finished(final_score) ──> ScoreOverlay
```

---

## Validation Rules

| Entity | Rule | Enforced By |
| ------ | ---- | ----------- |
| `CardData.id` | Unique across all 50 items | `CardPool.validate()` (called in `_ready`) |
| `CardData.front_texture` | Non-null | `CardPool.validate()` |
| `DifficultyPreset` | `pair_count * 2 == grid_columns * grid_rows` | `BoardManager.setup()` assertion |
| `CardInstance.board_position` | Unique per board | `BoardManager._shuffle_positions()` |
| `BoardState._pending` | Max 1 item | `BoardManager.on_card_selected()` guard |
| `ScoreCalculator` | `total_guesses >= 1` (guarded by `max(1, guesses)`) | `ScoreCalculator.calculate()` |
