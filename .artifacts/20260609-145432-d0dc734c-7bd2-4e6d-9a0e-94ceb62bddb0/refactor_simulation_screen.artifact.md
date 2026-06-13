# Refactor Simulation Screen (UI/UX & Logic)

Refactor `screen_simulation.dart` to clarify the primary call-to-action (CTA) and enforce strict exam logic regarding XP costs and history display.

## Proposed Changes

### Simulation Feature

#### [screen_simulation.dart](file:///C:/Users/ahmad/StudioProjects/miraiku/lib/features/simulation/screen_simulation.dart)

- **UI/UX - Primary CTA**:
    - Remove the existing `_buildUnlockButtonSection` and `_handleUnlock` / `_showStartConfirmation` complexity.
    - Add a prominent `ElevatedButton` labeled "Start Simulation" at the bottom of the `SingleChildScrollView` content.
    - Include a coin/star icon (`Icons.stars_rounded`) and "1500 XP" within the button.
- **Logic - XP Deduction**:
    - Implement `_startSimulationWithXP` logic:
        - Check `globalXP.value`.
        - If < 1500: Show `SnackBar` "Not enough XP to start the simulation.".
        - If >= 1500:
            - Wrap in `try-catch`.
            - Deduct 1500 XP.
            - Sync to cloud using `GameManager.syncToCloud()`.
            - Navigate to `SimulationTestScreen`.
- **Logic - History Limitation**:
    - Update `_showHistory` (or the way history is accessed) to ensure it only interacts with the single most recent entry.
    - Actually, since the requirement is to "ONLY retrieves and displays the single most recent mock exam result" for the "History icon/section" in `screen_simulation.dart`, I will modify how the history is displayed or accessed from this screen.
    - If the user clicks the history icon in `screen_simulation.dart`, it should ideally show the last result directly or a limited list.
    - I will also ensure that when saving new results (if I were modifying the result screen, but the prompt focuses on `screen_simulation.dart`), it doesn't stack. But the prompt specifically asks to refactor `screen_simulation.dart` and the "History icon/section" *on that screen*.

## Verification Plan

### Manual Verification
- **XP Logic**:
    - Set XP < 1500 and tap "Start Simulation". Verify SnackBar appears.
    - Set XP >= 1500 and tap "Start Simulation". Verify XP is deducted and navigation occurs.
- **UI Layout**:
    - Verify the new button is prominent and at the bottom of the scrollable area.
- **History**:
    - Verify that the history icon/section only shows the most recent result.
