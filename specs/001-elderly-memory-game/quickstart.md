# Quickstart: Elderly Brain Training Memory Matching Game

**Feature**: `001-elderly-memory-game`
**Phase**: 1 — Design
**Date**: 2026-05-03

This guide explains how to set up the Godot 4 project, install GdUnit4, add card assets,
run the test suite, and launch the game locally.

---

## Prerequisites

| Tool | Version | Where to get it |
| ---- | ------- | --------------- |
| Godot Engine | 4.3 or newer | https://godotengine.org/download |
| GdUnit4 addon | 4.x latest | https://github.com/MikeSchulze/gdUnit4/releases |
| Git | any modern | https://git-scm.com |

No other runtime dependencies are required. All game logic runs inside Godot.

---

## 1. Clone the Repository

```sh
git clone <repo-url> memory-game
cd memory-game
```

---

## 2. Open the Godot Project

1. Launch the Godot 4 editor.
2. Click **Import** and navigate to the repository root (`memory-game/`).
3. Select `project.godot` and click **Open**.

Godot will import all assets on first open. This may take 30–60 seconds for the
50 card textures.

---

## 3. Install GdUnit4 Addon

1. Download the GdUnit4 release ZIP from GitHub.
2. Unzip and copy the `addons/gdUnit4/` folder into the project root's `addons/`
   directory.
3. In the Godot editor: **Project → Project Settings → Plugins → GdUnit4 → Enable**.
4. Restart the editor when prompted.

Verify installation: the **GdUnit4** panel should appear at the bottom of the editor.

---

## 4. Add Card Front Textures

Place 50 PNG images into `assets/memory_game/card_fronts/`, named:

```
card_001.png
card_002.png
...
card_050.png
```

Images should be 256×256 px or larger (editor will scale). Thematic content: 1940s–1980s
animals, landscapes, everyday objects (see spec.md FR-004 for thematic detail).

Then, for each `CardData` resource in `assets/memory_game/card_data/`:
- Open in the Inspector.
- Assign the corresponding `front_texture` field.

> **Tip**: A helper script `tools/generate_card_data.gd` (to be created in Phase 2
> tasks) will automate `CardData` resource generation from the images folder.

---

## 5. Run the Test Suite

### In the Editor

1. Open the **GdUnit4** panel.
2. Click **Run All Tests**.
3. All tests in `tests/memory_game/` will execute.
4. Confirm all tests pass (green) before implementing new features.

### Headless (CI / Command Line)

```sh
godot --headless --path . \
  -s addons/gdUnit4/bin/GdUnitCmdTool.gd \
  --add tests/memory_game
```

Exit code 0 = all tests pass. Non-zero = at least one failure.

> **First run**: Tests will fail by design (TDD — tests are written before
> implementation). This is expected until each component is implemented.

---

## 6. Run the Game

1. In the Godot editor, open `scenes/memory_game/main_menu.tscn`.
2. Press **F5** (or click the **Play** button) to run from the main scene.
3. Select a difficulty level to start a game.

For a specific scene: open `scenes/memory_game/game_board.tscn` and press **F6**
(Play Current Scene). The board will start with the Easy preset by default when
launched standalone.

---

## 7. Project Settings to Verify

After first open, confirm these settings in **Project → Project Settings**:

| Setting | Expected Value |
| ------- | -------------- |
| `display/window/size/viewport_width` | 1920 |
| `display/window/size/viewport_height` | 1080 |
| `display/window/stretch/mode` | `canvas_items` |
| `display/window/stretch/aspect` | `keep` |
| `rendering/textures/canvas_textures/default_texture_filter` | `Nearest` (for pixel-art) or `Linear` |
| Script editor → All warnings | `Error` (enforces static-analysis gate) |

---

## 8. Input Map Actions

Verify these actions exist in **Project → Project Settings → Input Map**:

| Action | Default bindings |
| ------ | ---------------- |
| `ui_left` | Arrow Left, D-Pad Left, Left Stick Left |
| `ui_right` | Arrow Right, D-Pad Right, Left Stick Right |
| `ui_up` | Arrow Up, D-Pad Up, Left Stick Up |
| `ui_down` | Arrow Down, D-Pad Down, Left Stick Down |
| `ui_accept` | Space, Enter, Button South |

These are Godot's default actions; they should already exist. Add gamepad bindings
if not present.

---

## 9. Common Troubleshooting

| Problem | Fix |
| ------- | --- |
| GdUnit4 panel not appearing | Re-enable plugin in **Project Settings → Plugins** |
| Card textures show as pink/error | Ensure all 50 PNGs are in `assets/memory_game/card_fronts/` and assigned in `CardData` resources |
| Tests all fail immediately | Expected before implementation — this is TDD red phase |
| Board does not load on F6 | Add a default `DifficultyPreset` export variable in `GameSession` for standalone launch |
| Gamepad not responding | Check **Project Settings → Input Map** for gamepad bindings |
