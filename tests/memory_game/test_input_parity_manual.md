# Input Parity Manual Validation

Status: pending physical-device verification

## Mouse
- Launch the game from MainMenu using a click on each difficulty button.
- Hover cards on GameBoard and confirm focus highlight follows the hovered card.
- Click cards to flip them and confirm the focused card remains in sync with the clicked card.
- Click Return on GameBoard and confirm MainMenu is restored and GameBoard is freed.
- Complete a game, click Return to Menu on the score overlay, and confirm MainMenu is restored.

## Touch
- Launch the game using touch on each difficulty button.
- Tap cards to flip them and confirm the board remains responsive after matches and mismatches.
- Tap Hint when enabled and confirm highlighted cards are visible.
- Tap Return on GameBoard and on the score overlay and confirm scene transitions back to MainMenu.

## Keyboard
- On MainMenu, confirm initial focus starts on Easy and Up/Down moves between difficulty buttons.
- Press Enter or Space on a focused difficulty button and confirm GameBoard opens with the correct difficulty.
- On GameBoard, use arrow keys to move focus without wrapping unexpectedly.
- Confirm disabled or matched cards are skipped by directional navigation.
- Press Enter or Space on a focused card and confirm it flips.
- Complete a game and confirm the score overlay Return button receives focus automatically.

## Gamepad
- On MainMenu, confirm D-pad Up/Down moves focus between difficulty buttons.
- Press the south face button on a focused difficulty button to start the game.
- On GameBoard, use the D-pad to move focus across the grid.
- Confirm directional navigation skips matched cards and respects board bounds.
- Press the south face button to flip the focused card.
- Complete a game and confirm the score overlay Return button is immediately actionable.

## Notes
- Code-side support added in this change:
- MainMenu grabs initial focus and has explicit up/down focus neighbors.
- GameBoard cards are wrapped in square AspectRatioContainer nodes for responsive scaling.
- InputNavigator now skips disabled cards and keeps focus synchronized with actual UI focus.
- ScoreOverlay now gives focus to Return automatically for keyboard/gamepad parity.
