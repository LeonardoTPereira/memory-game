# Tasks: Elderly Brain Training Memory Matching Game

**Input**: Design documents from `/specs/001-elderly-memory-game/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Mandatory for gameplay logic and UI behaviour. For each logic component, write tests first, confirm failures, then implement. Maintain 100% game-logic coverage (constitution gate).

**Organization**: Tasks are grouped by user story and ordered for independent implementation and verification.

## Format: `[ID] [P?] [Story] Description with file path`

---

## Phase 1: Setup (Foundation & Assets)

**Purpose**: Create project skeleton, test harness, placeholders, and baseline config.

- [X] T001 Create project folder structure in scenes/memory_game/, scripts/memory_game/, assets/memory_game/card_fronts/, assets/memory_game/audio/, assets/memory_game/particles/, assets/memory_game/presets/, tests/memory_game/, tests/memory_game/page_objects/ (estimated time: 20 minutes)
- [ ] T002 Configure GdUnit4 addon and test bootstrap in addons/gdUnit4/ and project.godot (estimated time: 20 minutes)
- [ ] T003 [P] Add static analysis and warnings-as-errors settings in project.godot (estimated time: 10 minutes)
- [ ] T004 [P] Add headless test command documentation and coverage gate notes in specs/001-elderly-memory-game/quickstart.md (estimated time: 10 minutes)
- [X] T005 Create 50 placeholder card front assets card_001.png to card_050.png in assets/memory_game/card_fronts/ (estimated time: 45 minutes)
- [ ] T006 Create placeholder feedback assets correct.ogg and wrong.ogg in assets/memory_game/audio/ (estimated time: 15 minutes)
- [X] T007 Create placeholder particle scenes in assets/memory_game/particles/correct_particles.tscn and assets/memory_game/particles/wrong_particles.tscn (estimated time: 15 minutes)
- [ ] T008 Create typed resource scripts scripts/memory_game/card_data.gd and scripts/memory_game/difficulty_preset.gd (estimated time: 20 minutes)
- [ ] T009 Create difficulty preset resources assets/memory_game/presets/easy.tres, assets/memory_game/presets/medium.tres, assets/memory_game/presets/hard.tres (estimated time: 20 minutes)
- [X] T010 Define Input Map actions ui_left, ui_right, ui_up, ui_down, ui_accept with keyboard, mouse, touch, and gamepad defaults in project.godot (estimated time: 15 minutes)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared interfaces and scaffolding required by all stories.

- [ ] T011 Define typed signal contracts and payload conventions in scripts/memory_game/signal_contracts.md (estimated time: 15 minutes)
- [X] T012 Create pure scoring class skeleton in scripts/memory_game/score_calculator.gd (estimated time: 10 minutes)
- [X] T013 Create card pool class skeleton in scripts/memory_game/card_pool.gd (estimated time: 10 minutes)
- [X] T014 Create board manager class skeleton in scripts/memory_game/board_manager.gd (estimated time: 10 minutes)
- [X] T015 Create hint controller class skeleton in scripts/memory_game/hint_controller.gd (estimated time: 10 minutes)
- [ ] T016 Create card node class skeleton in scripts/memory_game/card.gd (estimated time: 10 minutes)
- [X] T017 Create game session orchestrator skeleton in scripts/memory_game/game_session.gd (estimated time: 10 minutes)
- [X] T018 Create input navigation skeleton in scripts/memory_game/input_navigator.gd (estimated time: 10 minutes)
- [ ] T019 Create UI page object skeletons in tests/memory_game/page_objects/po_hint_button.gd and tests/memory_game/page_objects/po_score_overlay.gd (estimated time: 15 minutes)
- [X] T020 Create baseline scene stubs in scenes/memory_game/main_menu.tscn, scenes/memory_game/game_board.tscn, scenes/memory_game/card.tscn, scenes/memory_game/score_overlay.tscn (estimated time: 25 minutes)

**Checkpoint**: Foundational layer complete. User-story work can proceed.

---

## Phase 3: User Story 1 - Select Difficulty and Start Game (Priority: P1) 🎯 MVP

**Goal**: Player can select Easy/Medium/Hard and start a randomized board with correct dimensions.

**Independent Test**: From main menu, choose each difficulty and verify 4x4/6x6/8x8 board with distinct sampled pairs and shuffled positions.

### Tests for User Story 1 (TDD first)

- [ ] T021 [P] [US1] Write failing unit tests for pair sampling count, uniqueness, and deterministic seed in tests/memory_game/test_card_pool.gd (estimated time: 35 minutes)
- [ ] T022 [US1] Confirm test_card_pool.gd fails for expected reasons before implementation in tests/memory_game/test_card_pool.gd (estimated time: 10 minutes)
- [ ] T023 [P] [US1] Write failing integration tests for difficulty-to-grid mapping and randomized board generation in tests/memory_game/test_board_setup.gd (estimated time: 35 minutes)
- [ ] T024 [US1] Confirm test_board_setup.gd fails for expected reasons before implementation in tests/memory_game/test_board_setup.gd (estimated time: 10 minutes)

### Implementation for User Story 1

- [ ] T025 [US1] Implement CardPool.sample_pairs(count, rng) with typed distinct selection in scripts/memory_game/card_pool.gd (estimated time: 30 minutes)
- [ ] T026 [US1] Implement CardPool.validate() for unique ids and non-null textures in scripts/memory_game/card_pool.gd (estimated time: 15 minutes)
- [ ] T027 [US1] Implement board setup flow and difficulty preset application in scripts/memory_game/board_manager.gd (estimated time: 40 minutes)
- [X] T028 [US1] Implement menu difficulty selection signal emission and scene transition in scenes/memory_game/main_menu.tscn and scripts/memory_game/main_menu.gd (estimated time: 30 minutes)
- [X] T029 [US1] Build game board layout containers and typed node bindings in scenes/memory_game/game_board.tscn (estimated time: 25 minutes)
- [ ] T030 [US1] Wire GameSession.start(preset) to BoardManager.setup(preset, grid) in scripts/memory_game/game_session.gd (estimated time: 20 minutes)
- [ ] T031 [US1] Add per-story static analysis pass and fix warnings in scripts/memory_game/card_pool.gd, scripts/memory_game/board_manager.gd, scripts/memory_game/game_session.gd, scripts/memory_game/main_menu.gd (estimated time: 15 minutes)
- [ ] T032 [US1] Verify story-scoped logic coverage for CardPool and board setup tests in tests/memory_game/test_card_pool.gd and tests/memory_game/test_board_setup.gd (estimated time: 15 minutes)

---

## Phase 4: User Story 2 - Flip Cards and Match Pairs (Priority: P1)

**Goal**: Player flips two cards, match logic resolves correctly, and invalid inputs are blocked.

**Independent Test**: Flip matching pair to remain face-up, flip mismatching pair to return face-down after delay, verify third selection is ignored during evaluation.

### Tests for User Story 2 (TDD first)

- [X] T033 [P] [US2] Write failing unit tests for score formula edge cases (zero guesses, perfect game, fractional floor) in tests/memory_game/test_score_calculator.gd (estimated time: 30 minutes)
- [X] T034 [US2] Confirm test_score_calculator.gd fails for expected reasons before implementation in tests/memory_game/test_score_calculator.gd (estimated time: 10 minutes)
- [ ] T035 [P] [US2] Write failing unit tests for card state machine, typed signals, and post-match lock in tests/memory_game/test_card_state.gd (estimated time: 35 minutes)
- [ ] T036 [US2] Confirm test_card_state.gd fails for expected reasons before implementation in tests/memory_game/test_card_state.gd (estimated time: 10 minutes)
- [X] T037 [P] [US2] Write failing integration tests for pair evaluation, wrong-guess increment, and completion detection in tests/memory_game/test_board_manager.gd (estimated time: 45 minutes)
- [X] T038 [US2] Confirm test_board_manager.gd fails for expected reasons before implementation in tests/memory_game/test_board_manager.gd (estimated time: 10 minutes)

### Implementation for User Story 2

- [X] T039 [US2] Implement ScoreCalculator.calculate(pairs_matched, total_guesses) as pure static function in scripts/memory_game/score_calculator.gd (estimated time: 20 minutes)
- [X] T040 [US2] Implement Card flip logic, FACE_DOWN/FACE_UP/MATCHED transitions, and card_selected signal in scripts/memory_game/card.gd (estimated time: 40 minutes)
- [X] T041 [US2] Implement card scene visuals and interaction wiring in scenes/memory_game/card.tscn (estimated time: 30 minutes)
- [X] T042 [US2] Implement BoardManager.on_card_selected() and _evaluate_pair() with typed signals pair_matched and wrong_guess_made in scripts/memory_game/board_manager.gd (estimated time: 50 minutes)
- [ ] T043 [US2] Implement evaluation-lock input blocking and third-selection rejection in scripts/memory_game/board_manager.gd (estimated time: 20 minutes)
- [X] T044 [US2] Connect card_selected from card instances to BoardManager in scripts/memory_game/game_session.gd (estimated time: 20 minutes)
- [ ] T045 [US2] Add per-story static analysis pass and fix warnings in scripts/memory_game/card.gd, scripts/memory_game/board_manager.gd, scripts/memory_game/score_calculator.gd (estimated time: 15 minutes)
- [ ] T046 [US2] Verify story-scoped logic coverage for card and board manager paths in tests/memory_game/test_card_state.gd and tests/memory_game/test_board_manager.gd (estimated time: 20 minutes)

---

## Phase 5: User Story 6 - Final Score and Return to Menu (Priority: P1)

**Goal**: When all pairs are matched, show final score overlay and return to menu via confirm or timeout.

**Independent Test**: Complete board, verify computed score display, confirm return button and auto-return both navigate to main menu.

### Tests for User Story 6 (TDD first)

- [ ] T047 [P] [US6] Write failing integration tests for game completion, score emission, and scene return flow in tests/memory_game/test_game_completion.gd (estimated time: 35 minutes)
- [ ] T048 [P] [US6] Write failing Page Object tests for score overlay value and return action in tests/memory_game/test_ui_hint_and_score.gd and tests/memory_game/page_objects/po_score_overlay.gd (estimated time: 35 minutes)
- [ ] T049 [US6] Confirm US6 tests fail for expected reasons before implementation in tests/memory_game/test_game_completion.gd (estimated time: 10 minutes)

### Implementation for User Story 6

- [X] T050 [US6] Implement game_finished(final_score: int) orchestration in scripts/memory_game/game_session.gd (estimated time: 25 minutes)
- [X] T051 [US6] Implement score overlay scene with value label, return button, and 5-second auto-return timer in scenes/memory_game/score_overlay.tscn and scripts/memory_game/score_overlay.gd (estimated time: 35 minutes)
- [X] T052 [US6] Connect BoardManager.all_pairs_matched to score computation and overlay presentation in scripts/memory_game/game_session.gd (estimated time: 20 minutes)
- [X] T053 [US6] Implement return-to-menu transition from score overlay in scripts/memory_game/score_overlay.gd and scripts/memory_game/main_menu.gd (estimated time: 20 minutes)
- [ ] T054 [US6] Add per-story static analysis pass and fix warnings in scripts/memory_game/game_session.gd and scripts/memory_game/score_overlay.gd (estimated time: 10 minutes)
- [ ] T055 [US6] Verify story-scoped logic and UI coverage for completion and score paths in tests/memory_game/test_game_completion.gd and tests/memory_game/test_ui_hint_and_score.gd (estimated time: 15 minutes)

---

## Phase 6: User Story 3 - Match Feedback (Priority: P2)

**Goal**: Correct/wrong outcomes produce immediate text, particles, sounds, and temporary input blocking.

**Independent Test**: Trigger correct and wrong evaluations and verify CORRETO/ERRADO text, particle scenes, sound cues, and unblock timing.

### Tests for User Story 3 (TDD first)

- [ ] T056 [P] [US3] Write failing integration tests for feedback payload and input blocking window in tests/memory_game/test_feedback_flow.gd (estimated time: 35 minutes)
- [ ] T057 [P] [US3] Write failing UI tests for feedback text lifecycle in tests/memory_game/test_ui_feedback.gd (estimated time: 30 minutes)
- [ ] T058 [US3] Confirm US3 tests fail for expected reasons before implementation in tests/memory_game/test_feedback_flow.gd (estimated time: 10 minutes)

### Implementation for User Story 3

- [X] T059 [US3] Add feedback layer nodes and bindings in scenes/memory_game/game_board.tscn (estimated time: 20 minutes)
- [X] T060 [US3] Implement correct feedback pipeline (green particles, correct sound, CORRETO text) in scripts/memory_game/game_session.gd (estimated time: 25 minutes)
- [X] T061 [US3] Implement wrong feedback pipeline (red particles, wrong sound, ERRADO text, clear timer) in scripts/memory_game/game_session.gd (estimated time: 25 minutes)
- [ ] T062 [US3] Enforce temporary input lock while feedback is active in scripts/memory_game/board_manager.gd and scripts/memory_game/game_session.gd (estimated time: 20 minutes)
- [ ] T063 [US3] Add per-story static analysis pass and fix warnings in scripts/memory_game/game_session.gd and scripts/memory_game/board_manager.gd (estimated time: 10 minutes)
- [ ] T064 [US3] Verify story-scoped coverage for feedback branch logic in tests/memory_game/test_feedback_flow.gd (estimated time: 15 minutes)

---

## Phase 7: User Story 4 - Hint System (Priority: P2)

**Goal**: Hint button enables after 10 wrong guesses, highlights random unmatched pair, and resets hint counter.

**Independent Test**: Simulate wrong guesses to threshold, press hint, verify distinct highlight and counter reset.

### Tests for User Story 4 (TDD first)

- [X] T065 [P] [US4] Write failing unit tests for hint threshold and reset behaviour in tests/memory_game/test_hint_controller.gd (estimated time: 35 minutes)
- [ ] T066 [P] [US4] Write failing Page Object test for hint button enabled/disabled state transitions in tests/memory_game/test_ui_hint_and_score.gd and tests/memory_game/page_objects/po_hint_button.gd (estimated time: 30 minutes)
- [ ] T067 [P] [US4] Write failing integration test for random unmatched pair highlight duration and style in tests/memory_game/test_hint_integration.gd (estimated time: 35 minutes)
- [X] T068 [US4] Confirm US4 tests fail for expected reasons before implementation in tests/memory_game/test_hint_controller.gd (estimated time: 10 minutes)

### Implementation for User Story 4

- [X] T069 [US4] Implement HintController counter tracking, eligibility signal, and request_hint() in scripts/memory_game/hint_controller.gd (estimated time: 30 minutes)
- [X] T070 [US4] Connect wrong_guess_made and hint button pressed flows in scripts/memory_game/game_session.gd (estimated time: 20 minutes)
- [X] T071 [US4] Implement BoardManager.get_unmatched_pairs() and random pair selection for hints in scripts/memory_game/board_manager.gd (estimated time: 25 minutes)
- [X] T072 [US4] Implement card hint highlight style and timeout reset distinct from focus state in scripts/memory_game/card.gd and scenes/memory_game/card.tscn (estimated time: 30 minutes)
- [X] T073 [US4] Add hint button UI state transitions in scenes/memory_game/game_board.tscn (estimated time: 15 minutes)
- [ ] T074 [US4] Add per-story static analysis pass and fix warnings in scripts/memory_game/hint_controller.gd, scripts/memory_game/game_session.gd, scripts/memory_game/card.gd (estimated time: 10 minutes)
- [ ] T075 [US4] Verify story-scoped coverage for hint threshold and reset branches in tests/memory_game/test_hint_controller.gd and tests/memory_game/test_hint_integration.gd (estimated time: 15 minutes)

---

## Phase 8: User Story 5 - Keyboard and Gamepad Control (Priority: P2)

**Goal**: Full non-mouse navigation in menu and board with visible focus highlight and accept action.

**Independent Test**: Start game using keyboard/gamepad only, move focus across grid predictably, flip cards with accept input.

### Tests for User Story 5 (TDD first)

- [ ] T076 [P] [US5] Write failing integration tests for directional grid navigation and no unexpected wrapping in tests/memory_game/test_input_navigator.gd (estimated time: 35 minutes)
- [ ] T077 [P] [US5] Write failing UI tests for visible focus highlight in menu and card grid in tests/memory_game/test_ui_focus_accessibility.gd (estimated time: 30 minutes)
- [ ] T078 [US5] Confirm US5 tests fail for expected reasons before implementation in tests/memory_game/test_input_navigator.gd (estimated time: 10 minutes)

### Implementation for User Story 5

- [X] T079 [US5] Implement InputNavigator._unhandled_input() and _move_focus(delta) in scripts/memory_game/input_navigator.gd (estimated time: 40 minutes)
- [X] T080 [US5] Integrate InputNavigator with GameSession and focusable card list updates in scripts/memory_game/game_session.gd (estimated time: 20 minutes)
- [X] T081 [US5] Implement focus highlight visuals for cards and menu buttons in scripts/memory_game/card.gd, scenes/memory_game/card.tscn, and scenes/memory_game/main_menu.tscn (estimated time: 30 minutes)
- [ ] T082 [US5] Validate mouse, touch, keyboard, and gamepad parity flows in tests/memory_game/test_input_parity_manual.md (estimated time: 20 minutes)
- [ ] T083 [US5] Add per-story static analysis pass and fix warnings in scripts/memory_game/input_navigator.gd and scripts/memory_game/game_session.gd (estimated time: 10 minutes)
- [ ] T084 [US5] Verify story-scoped coverage for navigation and accept-flow logic in tests/memory_game/test_input_navigator.gd (estimated time: 15 minutes)

---

## Phase 9: Polish and Cross-Cutting

**Purpose**: Accessibility, responsiveness, global validation, and release-ready docs.

- [X] T085 [P] Create shared UI theme with >=24px typography and accessible contrast in assets/memory_game/theme.tres and apply in scenes/memory_game/main_menu.tscn, scenes/memory_game/game_board.tscn, scenes/memory_game/score_overlay.tscn (estimated time: 30 minutes)
- [X] T086 [P] Implement responsive scaling and square-card constraints with GridContainer + AspectRatioContainer in scenes/memory_game/game_board.tscn (estimated time: 25 minutes)
- [ ] T087 Add manual acceptance checklist for all spec criteria in specs/001-elderly-memory-game/checklists/acceptance.md (estimated time: 30 minutes)
- [ ] T088 Execute full GdUnit4 suite and capture results in specs/001-elderly-memory-game/checklists/test-results.md (estimated time: 20 minutes)
- [ ] T089 Verify 100% game-logic coverage and report in specs/001-elderly-memory-game/checklists/coverage.md (estimated time: 20 minutes)
- [ ] T090 Run static analysis and resolve all warnings in scripts/memory_game/*.gd and record output in specs/001-elderly-memory-game/checklists/static-analysis.md (estimated time: 20 minutes)
- [ ] T091 Create concise run/build/test guide in README.md (estimated time: 25 minutes)
- [ ] T092 Run quickstart validation pass and correct any drift in specs/001-elderly-memory-game/quickstart.md (estimated time: 15 minutes)

---

## Dependencies and Execution Order

### Phase Dependencies

- Setup (Phase 1): no dependencies.
- Foundational (Phase 2): depends on Setup and blocks all user stories.
- User stories (Phases 3-8): depend on Foundational.
- Polish (Phase 9): depends on completion of required user stories.

### User Story Dependencies

- US1 (P1): starts after Foundational; enables board creation for all gameplay.
- US2 (P1): depends on US1 board startup.
- US6 (P1): depends on US2 completion detection and scoring.
- US3 (P2): depends on US2 match outcome events.
- US4 (P2): depends on US2 wrong-guess tracking and US3 feedback timing.
- US5 (P2): depends on US1 scenes and US2 card interaction.

### Within Each Story

- Tests must be written first and fail before implementation.
- Implement core logic after failing tests are verified.
- Run static analysis and coverage checks before closing the story.

---

## Parallel Execution Opportunities

- Setup: T003 and T004 can run with asset tasks T005 to T007.
- Foundational: T012 to T019 can run in parallel across separate files.
- US1: T021 and T023 in parallel; T025 and T028 in parallel.
- US2: T033, T035, T037 in parallel test authoring; T039 and T041 in parallel.
- US6: T047 and T048 in parallel.
- US3: T056 and T057 in parallel.
- US4: T065, T066, T067 in parallel.
- US5: T076 and T077 in parallel.
- Polish: T085 and T086 in parallel; T088 to T090 can be batched after code freeze.

---

## Parallel Example: User Story 2

- T033 [P] [US2] Write failing unit tests in tests/memory_game/test_score_calculator.gd
- T035 [P] [US2] Write failing unit tests in tests/memory_game/test_card_state.gd
- T037 [P] [US2] Write failing integration tests in tests/memory_game/test_board_manager.gd

After these fail, run implementation sequence T039 -> T040 -> T042 -> T043.

---

## Implementation Strategy

### MVP First

1. Finish Phase 1 and Phase 2.
2. Deliver US1 (board start) and US2 (core matching loop).
3. Add US6 (game closure and score) to complete a playable loop.
4. Validate with automated tests and manual smoke checks.

### Incremental Delivery

1. Add US3 (feedback) after MVP.
2. Add US4 (hint) for elderly support.
3. Add US5 (full keyboard/gamepad accessibility).
4. Execute Phase 9 final validation gates.

### Definition of Done Alignment

- All mandatory tests pass in tests/memory_game/.
- 100% game-logic coverage achieved (constitution gate; supersedes 80% minimum target).
- Static analysis passes with no unresolved warnings.
- Accessibility constraints met (>=24px text, clear focus/highlight, multi-input parity).
- README.md and quickstart instructions are validated.
