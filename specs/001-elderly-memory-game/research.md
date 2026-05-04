# Research: Elderly Brain Training Memory Matching Game

**Feature**: `001-elderly-memory-game`
**Phase**: 0 — Pre-design unknowns resolved
**Date**: 2026-05-03

---

## Research Questions and Decisions

### 1. GdUnit4 Integration Approach

**Question**: Which GdUnit4 version and integration method for Godot 4?

**Decision**: GdUnit4 v4.x installed as a Godot project addon (`addons/gdUnit4/`).
Tests are discovered automatically by the addon's test runner and executed via
`godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd` for CI.

**Rationale**: The addon approach keeps test infrastructure inside the Godot project,
requires no separate test binary, and integrates cleanly with the Godot editor's
built-in test panel for local development.

**Alternatives considered**:
- External Python test harness: rejected — adds a second language and tool dependency.
- gdUnit3: rejected — targets Godot 3 only.

---

### 2. Signal Bus: Autoload EventBus vs. Local Signals

**Question**: Should cross-component events use a global autoload `EventBus` singleton
or direct signal connections between nodes?

**Decision**: **Local signals with typed payloads**, connected in `GameSession` during
`_ready()`. No global autoload singleton for gameplay signals.

**Rationale**: The game board scene is self-contained and short-lived (one game session).
A global bus would make signal lifetime management error-prone (connections surviving
scene changes). Local connections via `connect()` in `GameSession._ready()` are explicit,
debuggable, and testable by injecting mock emitters. The `game_finished` signal flows
upward from `GameSession` to the scene manager (a thin autoload `SceneManager`) which
handles the scene transition — this is the only autoload in the project.

**Alternatives considered**:
- Global autoload EventBus for all signals: rejected — implicit coupling and lifecycle
  bugs when scenes are freed while listeners remain connected.
- Direct `get_parent()` calls instead of signals: rejected — violates signal-driven
  decoupling principle from constitution.

---

### 3. Card Flip Animation: AnimationPlayer vs. Tween

**Question**: Which animation system for card flip (face-down ↔ face-up)?

**Decision**: **`Tween`** created on demand in `Card.flip_face_up()` /
`Card.flip_face_down()`.

Implementation sketch:
```gdscript
func flip_face_up() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "scale:x", 0.0, 0.15)
    tween.tween_callback(_swap_textures)
    tween.tween_property(self, "scale:x", 1.0, 0.15)
```

**Rationale**: `Tween` requires no `.tres`/`.anim` asset file, is fully code-driven,
and is straightforward to unit-test by inspecting `face_state` after awaiting
`tween.finished`. `AnimationPlayer` would require a tracked animation resource file per
card, adding asset maintenance overhead for what is a simple scale-based flip.

**Alternatives considered**:
- `AnimationPlayer` with a shared `flip.anim` resource: viable but heavier; animation
  tracks are harder to vary per card (front texture differs per card).
- Shader-based 3D flip: rejected — adds shader complexity for no visual benefit in a
  2D UI game.

---

### 4. Preloading 50 Card Images

**Question**: How to load 50 card-front images efficiently without runtime stutter?

**Decision**: `CardPool` resource holds an `@export var all_cards: Array[CardData]`
where each `CardData` resource has `@export var front_texture: Texture2D` set to a
`preload()` reference in the Godot editor (assigned in the Inspector, not at runtime).
Because `preload()` is a compile-time directive, all textures are bundled and available
immediately when `CardPool` is loaded.

**Rationale**: `preload()` ensures all textures are loaded before the scene starts;
avoids `ResourceLoader.load()` async latency on game start; keeps assets declarative
and editor-inspectable.

**Alternatives considered**:
- `ResourceLoader.load_threaded()` at runtime: viable for larger asset sets but adds
  async complexity and a loading-screen requirement for what is a small 50-image pool.
- Packed sprite atlas: viable but requires additional tooling and is not necessary at
  this scale.

---

### 5. Hint Highlight Visual Distinction

**Question**: How to highlight a hinted pair in a way distinct from keyboard focus
and from normal card appearance?

**Decision**: `Card` exposes a `FocusState` enum with three values: `UNFOCUSED`,
`FOCUSED`, `HINT_HIGHLIGHTED`. The `FocusHighlight` `ColorRect` uses a blue tint; the
`HintHighlight` `ColorRect` uses a gold/yellow tint with a pulsing animation driven by
a `Tween`. Both highlights use shape (coloured border overlay), not colour alone.
Screen reader / high-contrast mode: border thickness ≥ 4 px.

**Rationale**: Colour-blind users can distinguish focus (blue, thin) from hint
(gold, thick, animated pulse) by shape and motion. The constitution prohibits
colour-only critical signalling.

---

### 6. Godot 4 GridContainer Scaling for Multiple Resolutions

**Question**: How to make an 8×8 card grid scale correctly from 720p to 4K?

**Decision**: `GridContainer` is wrapped in an `AspectRatioContainer` (ratio = grid
width/height) which is itself anchored to fill the available play area. Card
`custom_minimum_size` is set to `Vector2(64, 64)` and the container's `expand` policy
handles overflow. Project base resolution is 1920×1080 with `stretch_mode = canvas_items`
and `aspect = keep`.

**Alternatives considered**:
- Fixed pixel sizes: rejected — breaks on non-1080p screens.
- `SubViewport` with fixed resolution: rejected — adds compositor overhead and complicates
  input handling.

---

## Summary of Resolved Unknowns

| Unknown | Resolution |
| ------- | ---------- |
| GdUnit4 version/integration | v4.x as addon, headless CI via `GdUnitCmdTool.gd` |
| Signal architecture | Local typed signals connected in `GameSession._ready()` |
| Card flip animation | `Tween` (code-driven, no `.anim` asset) |
| 50-image preloading | `preload()` in `CardData` resources, assigned in Inspector |
| Hint highlight vs focus | `FocusState` enum; blue border for focus, gold pulse for hint |
| Grid scaling | `AspectRatioContainer` + `stretch_mode = canvas_items` at 1080p base |
