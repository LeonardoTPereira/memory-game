# Feature Specification: Elderly Brain Training Memory Matching Game

**Feature Branch**: `001-elderly-memory-game`
**Created**: 2026-05-03
**Status**: Draft
**Input**: User description: "Build a memory matching game for elderly brain training"

---

## User Scenarios & Testing *(mandatory)*

<!--
  User stories are ordered by priority. Each is independently testable as a
  viable game slice.
-->

### User Story 1 – Select Difficulty and Start a Game (Priority: P1)

A player opens the application, sees the main menu, selects a difficulty level
(Easy, Medium, or Hard), and a properly sized board of face-down cards appears,
ready to play.

**Why this priority**: Without a working menu and board setup, no other story
can be played. This is the entry gate for all other interactions.

**Independent Test**: Launch the game, pick a difficulty, and verify the correct
number of unique card pairs appear face-down and randomly distributed — no further
interaction is needed to confirm this story delivers value.

**Acceptance Scenarios**:

1. **Given** the application has launched, **When** the player views the main menu,
   **Then** three difficulty options are displayed: Easy (4×4, 8 pairs), Medium (6×6,
   18 pairs), and Hard (8×8, 32 pairs), each labelled clearly with grid size and pair
   count.
2. **Given** the player selects Easy, **When** the board loads, **Then** 16 cards are
   arranged in a 4×4 grid, each showing its back face, drawn randomly from the 50-pair
   pool without repetition.
3. **Given** the player selects Medium, **When** the board loads, **Then** 36 cards
   are arranged in a 6×6 grid with 18 unique pairs, randomly selected and shuffled.
4. **Given** the player selects Hard, **When** the board loads, **Then** 64 cards are
   arranged in an 8×8 grid with 32 unique pairs, randomly selected and shuffled.
5. **Given** two consecutive games at the same difficulty, **When** both boards are
   observed, **Then** pair selection and card positions differ (random, not fixed).

---

### User Story 2 – Flip Cards and Match Pairs (Priority: P1)

A player clicks (or taps / presses) a face-down card to reveal its image, then selects
a second card. The game evaluates whether the two cards are a matching pair.

**Why this priority**: Core gameplay mechanic — everything else depends on the
flip-and-match loop working correctly.

**Independent Test**: Start a game, flip two matching cards, verify they stay face-up.
Flip two non-matching cards, verify they flip back. Both branches are independently
testable without any other story.

**Acceptance Scenarios**:

1. **Given** a card is face-down and no other card is currently face-up, **When** the
   player selects it, **Then** the card animates to face-up and reveals its image.
2. **Given** one card is already face-up, **When** the player selects a second face-down
   card, **Then** the second card flips face-up and match evaluation occurs.
3. **Given** both revealed cards share the same image identity, **When** evaluation
   runs, **Then** both cards remain permanently face-up and the matched-pair count
   increases by one.
4. **Given** both revealed cards have different image identities, **When** evaluation
   runs, **Then** both cards flip back face-down after a short delay and the wrong-guess
   count increases by one.
5. **Given** one card is already face-up awaiting a second selection, **When** the
   player attempts to select a third card or the already face-up card, **Then** that
   input is ignored.
6. **Given** a card is already matched and permanently face-up, **When** the player
   selects it, **Then** the input is ignored.

---

### User Story 3 – Receive Feedback on Match Outcome (Priority: P2)

After each pair evaluation, the player receives immediate visual and audio feedback
that confirms whether the guess was correct or wrong.

**Why this priority**: Feedback is core to the brain-training loop; delayed or absent
feedback breaks the learning signal. Depends on User Story 2.

**Independent Test**: Force a correct match and verify green particles, cheerful sound,
and "CORRETO" text appear. Force a wrong match and verify red particles, sad sound,
and "ERRADO" text appear.

**Acceptance Scenarios**:

1. **Given** a correct match is made, **When** feedback plays, **Then** green particle
   effects appear near the matched cards, a cheerful audio cue plays, and large
   "CORRETO" text is displayed prominently on screen.
2. **Given** a wrong match is made, **When** feedback plays, **Then** red particle
   effects appear near the cards, a sad audio cue plays, and large "ERRADO" text is
   displayed prominently on screen.
3. **Given** either feedback is displayed, **When** its duration expires, **Then** text
   and particles clear automatically and the board returns to interactive state.
4. **Given** feedback is in progress, **When** the player attempts to flip another card,
   **Then** the input is ignored until feedback completes.

---

### User Story 4 – Use the Hint System (Priority: P2)

After 10 wrong guesses since the last hint (or since game start), a Hint button becomes
active. The player may press it to briefly highlight a random unmatched pair, helping
them progress without external assistance.

**Why this priority**: Supports the elderly brain-training context by reducing
frustration without removing challenge. Depends on User Story 2 wrong-guess counting.

**Independent Test**: Trigger 10 wrong guesses, verify the Hint button becomes
enabled, press it, verify a pair of unmatched cards highlights briefly, confirm
wrong-guess counter resets to zero for hint eligibility.

**Acceptance Scenarios**:

1. **Given** the game has started, **When** fewer than 10 wrong guesses have occurred
   since the last hint use (or game start), **Then** the Hint button is visually
   disabled and cannot be activated.
2. **Given** exactly 10 wrong guesses have occurred since last hint use, **When** the
   player views the Hint button, **Then** it becomes visually enabled and interactive.
3. **Given** the Hint button is enabled, **When** the player activates it, **Then** one
   random unmatched pair of cards is briefly highlighted to distinguish it from all
   other cards, and the wrong-guess counter for hint eligibility resets to zero.
4. **Given** the hint highlight is active, **When** the player selects one of the
   highlighted cards, **Then** normal match-evaluation behaviour proceeds.
5. **Given** a hint is used and the pair is not selected before the highlight expires,
   **When** the highlight timer runs out, **Then** the cards return to normal appearance
   and the player continues without the hint having counted as a wrong guess.

---

### User Story 5 – Control the Game with Keyboard or Gamepad (Priority: P2)

A player who cannot or prefers not to use a mouse or touch screen can navigate the
board and menus using keyboard arrows + spacebar or a gamepad (left stick/d-pad +
accept button). A visual focus highlight shows the currently selected item.

**Why this priority**: Accessibility requirement; elderly players may have limited
fine-motor control. Depends on User Story 1 and 2.

**Independent Test**: Start the game without a mouse, navigate to a card using arrow
keys, press spacebar to flip it, confirm it flips — independently verifiable.

**Acceptance Scenarios**:

1. **Given** the main menu is displayed, **When** the player uses directional input
   (keyboard arrows or d-pad/left stick), **Then** the focus highlight moves between
   difficulty options in the expected direction.
2. **Given** a menu item is focused, **When** the player presses the accept input
   (spacebar or gamepad accept button), **Then** the same action as a click/tap occurs.
3. **Given** a card grid is active, **When** the player uses directional input, **Then**
   the focus highlight moves between adjacent cards in the grid without wrapping to an
   unexpected position.
4. **Given** a face-down card is focused, **When** the player presses accept, **Then**
   the card flips, identical to a click/tap selection.
5. **Given** any interactive element is focused, **When** the player uses any supported
   input device, **Then** the focus highlight is always clearly visible against all
   background and card colours.

---

### User Story 6 – View Final Score and Return to Menu (Priority: P1)

When all pairs on the board are matched, the game displays the final score using the
defined formula, then returns the player to the main menu.

**Why this priority**: Closes the game loop. Without it the game has no conclusion
or replayability.

**Independent Test**: Complete all pairs on an Easy board, verify the score overlay
appears with a valid score value, confirm pressing confirm returns to the main menu.

**Acceptance Scenarios**:

1. **Given** the last pair on the board is matched, **When** the match animation
   completes, **Then** a final-score overlay appears displaying the numerical score
   computed as `(TotalPairsFound / TotalGuessesMade) × 1000`, rounded to a whole
   number.
2. **Given** the score overlay is visible, **When** the player confirms or waits for
   the auto-dismiss timer, **Then** the main menu is displayed again.
3. **Given** a game where every guess was correct (zero wrong guesses), **When** the
   score is computed, **Then** the result equals exactly 1000.
4. **Given** a game where the player made more guesses than the minimum possible,
   **When** the score is computed, **Then** the result is less than 1000 and greater
   than 0.
5. **Given** the score overlay is shown, **When** the player views it, **Then** the
   score value and a brief contextual label are displayed in a font size and contrast
   that meets the 24px minimum at 1080p.

---

### Edge Cases

- What happens when the hint is requested but no unmatched pairs remain?
  — This state cannot occur because the game ends when all pairs are matched.
- What happens if a player rapidly clicks multiple cards before a flip animation
  finishes? — Inputs beyond the two-card evaluation window MUST be queued or
  discarded; the board MUST NOT enter an inconsistent state.
- What happens if screen resolution is below 1080p? — Accessibility constraints
  SHOULD scale proportionally; the 24px and 48px minimums are baselines at 1080p.
- What happens when 10 wrong guesses occur and there is only one unmatched pair left?
  — The hint highlights that pair normally.

---

## Requirements *(mandatory)*

### Functional Requirements

#### Main Menu and Game Setup

- **FR-001**: The game MUST display a main menu with three clearly labelled difficulty
  options: Easy (4×4 grid, 8 pairs), Medium (6×6 grid, 18 pairs), and Hard
  (8×8 grid, 32 pairs).
- **FR-002**: The game MUST maintain a pool of exactly 50 unique card-image pairs.
- **FR-003**: At game start, the game MUST randomly select the required number of pairs
  from the 50-pair pool without repetition, then shuffle the resulting cards into
  random board positions.
- **FR-004**: Card images MUST depict items from the 1940s–1980s era — including but
  not limited to animals, landscapes, vintage cars, rotary phones, and record players —
  rendered in a vivid, nostalgic, high-contrast visual style.

#### Card Interaction

- **FR-005**: The game MUST allow the player to reveal a face-down card by: mouse
  click, touch tap, keyboard spacebar (when the card is focused), or gamepad accept
  button (when the card is focused).
- **FR-006**: The game MUST allow only one card to be in the "pending second selection"
  state at a time; additional inputs during this state MUST be ignored.
- **FR-007**: The game MUST evaluate pairs immediately once two cards are face-up in
  the evaluation window.

#### Match Outcome Feedback

- **FR-008**: WHEN a correct match is evaluated, the game MUST display large "CORRETO"
  text on screen, trigger green particle effects near the matched cards, and play a
  cheerful audio cue simultaneously.
- **FR-009**: WHEN a wrong match is evaluated, the game MUST display large "ERRADO"
  text on screen, trigger red particle effects near the cards, and play a sad audio
  cue simultaneously; both cards MUST flip back face-down after a short delay.
- **FR-010**: The wrong-guess count MUST increase by one for each wrong match.
- **FR-011**: While match feedback is active, all card-selection inputs MUST be blocked.

#### Hint System

- **FR-012**: The game MUST display a Hint button that becomes interactive only when
  the player has accumulated 10 wrong guesses since the last hint use (or since game
  start).
- **FR-013**: WHEN the Hint button is activated, the game MUST briefly highlight one
  randomly selected unmatched pair and reset the wrong-guess counter for hint
  eligibility to zero.
- **FR-014**: The hint highlight MUST be visually distinct from normal card appearance
  and from the keyboard/gamepad focus highlight.

#### Scoring and Game Over

- **FR-015**: The game MUST track the total number of pairs found and the total number
  of guesses made throughout each play session.
- **FR-016**: WHEN all pairs on the board are matched, the game MUST compute the final
  score using the formula: `Score = (TotalPairsFound / TotalGuessesMade) × 1000`,
  rounded to the nearest whole number.
- **FR-017**: The final score MUST be displayed to the player before the game returns
  to the main menu.
- **FR-018**: The game MUST NOT impose any turn limit or lives system; players MUST be
  free to guess without penalty beyond score impact.

#### Accessibility

- **FR-019**: All interactive buttons and controls MUST have a minimum touch/click
  target size of 48×48 logical pixels.
- **FR-020**: All body and label text MUST use a clear, legible sans-serif typeface at
  a minimum equivalent of 24px at 1080p resolution; text MUST scale proportionally
  with viewport.
- **FR-021**: The card grid MUST scale to fit the viewport without truncation on
  supported screen sizes.
- **FR-022**: The keyboard and gamepad focus highlight MUST be visually unambiguous;
  critical game states MUST NOT be communicated by colour alone.

#### Audio

- **FR-023**: The game MUST include distinct cheerful and sad audio cues for correct
  and wrong match outcomes respectively, with a nostalgic, cheerful overall audio
  theme.
- **FR-024**: Audio cues MUST play promptly (no perceptible delay) on match evaluation.

### Constitution Alignment *(mandatory)*

- **CA-001 Composition-First Architecture**: The board, card, feedback overlay, hint
  system, and score display are independent behavioural components. No component MUST
  inherit game-logic behaviour from another; all composition boundaries MUST be
  explicit. Inheritance is permitted only for stable Godot-node base classes.
- **CA-002 Signal-Driven Decoupling**: Card-flip events, match outcomes, wrong-guess
  count changes, and game-over conditions MUST be communicated via typed signals.
  Components MUST NOT traverse node paths to call sibling or parent logic directly.
- **CA-003 Static Typing and SOLID**: All GDScript written for this feature MUST use
  static typing for variables, function parameters, return types, and signal payloads.
  Each script MUST have a single clearly stated responsibility (e.g., CardState,
  BoardLayout, ScoreTracker, HintController). God-object scripts are prohibited.
- **CA-004 Test and Coverage Enforcement**: Game-logic classes (pair-matching
  evaluation, score calculation, hint eligibility, card-state machine, pair-selection
  randomization) MUST be covered at 100% line and branch coverage using GdUnit4.
  UI scenes MUST have Page Object wrappers for any automated UI test. All tests MUST
  fail before implementation begins.
- **CA-005 Analysis and Quality Gates**: All GDScript MUST pass Godot 4's built-in
  static analysis with no suppressed warnings. The project MUST define a CI gate that
  fails on analysis errors. Particle, audio, and animation subsystems MUST emit debug
  logs when in development mode.

### Key Entities *(feature involves data)*

- **CardIdentity**: The unique identifier and image reference for one half of a pair.
  Attributes: id (unique integer), image key, era category, display name.
- **CardInstance**: A single card on the board at a given position. Attributes:
  identity (CardIdentity), board position, face state (face-down / face-up /
  matched), focus state (unfocused / focused / hint-highlighted).
- **BoardState**: The complete set of CardInstances for the current game, the current
  face-up selection window, matched-pair count, total-guesses count,
  wrong-guess count for hint eligibility.
- **DifficultyLevel**: Enum of Easy / Medium / Hard, carrying grid dimensions and
  required pair count.
- **ScoreResult**: Computed at game end. Attributes: pairs found, total guesses,
  final score (integer).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Players can begin a game at any difficulty and see a fully populated,
  shuffled board within 3 seconds of selecting difficulty on target hardware.
- **SC-002**: Match outcome feedback (text, particles, sound) appears within 200ms of
  the second card being revealed.
- **SC-003**: A player using only keyboard or gamepad can complete a full Easy-mode
  game without using a mouse or touch screen.
- **SC-004**: All interactive elements are reachable and activatable by a player using
  only keyboard arrow keys and spacebar.
- **SC-005**: The final score for a perfect game (no wrong guesses) always equals
  exactly 1000; the formula produces consistent, deterministic results for any given
  pair/guess count.
- **SC-006**: Game logic (matching, scoring, hint eligibility, card state) achieves
  100% automated test coverage using GdUnit4 before the feature ships.
- **SC-007**: All static-analysis checks pass with zero suppressed warnings before
  the feature is merged.
- **SC-008**: In a usability session with target users (age 60+), ≥80% of participants
  can locate and use the Hint button without external assistance after one wrong-match
  experience.

---

## Assumptions

- The 50-pair card image pool is provided as art assets prior to implementation;
  the specification defines the thematic content but does not prescribe asset format.
- Scores are not persisted across sessions; each game session produces a single
  ephemeral score displayed at game end.
- The target minimum screen resolution for accessibility compliance is 1080p;
  scaling behaviour on lower resolutions is best-effort.
- Gamepad support targets a standard two-analog-stick controller layout; specific
  hardware compatibility is outside this feature's scope.
- No network or leaderboard features are required for this version.
- Audio assets (cheerful/sad cues, background theme) are provided as part of the
  project asset pipeline; this specification defines tonal and contextual requirements.
- The "short delay" before wrong-match cards flip back is between 1 and 2 seconds;
  exact timing is a design decision during implementation.
