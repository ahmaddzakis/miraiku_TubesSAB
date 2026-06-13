# Refactor Exam Result and Exam Review Screens

Refactor the Simulation Result and Review screens to improve professional UI/UX and logic, focusing on dynamic time display, accuracy clarity, and improved navigation controls.

## Proposed Changes

### Simulation Feature

#### [simulation_result_screen.dart](file:///C:/Users/ahmad/StudioProjects/miraiku/lib/features/simulation/simulation_result_screen.dart)

- **Accuracy Clarity**: Add a subtitle below the "Accuracy" percentage to explain what it means.
- **Dynamic Time**: Ensure `timeSpentSeconds` is used correctly (it already seems to be passed in, but I will double-check the caller if necessary, though the requirement is to ensure it's not hardcoded in the UI). I will keep the existing `_formatDuration` logic as it already cleanly formats the time.
- Update `_buildSmallStatCard` to support an optional subtitle.

#### [simulation_review_screen.dart](file:///C:/Users/ahmad/StudioProjects/miraiku/lib/features/simulation/simulation_review_screen.dart)

- **Conditional Pagination**:
    - Hide the "PREVIOUS" button when on the first question.
    - Change "NEXT" button to "DONE" (already exists, but will ensure it's prominent) on the last question.
    - If hiding "PREVIOUS", ensure "NEXT" takes full width or maintain layout consistency as requested. Actually, the requirement says "Hide or disable". I will go with hiding for a cleaner look if it's the first question, but ensuring the "NEXT" button still feels balanced.

## Verification Plan

### Manual Verification
- **Result Screen**:
    - Verify that the "Accuracy" card now has a subtitle "Correct answer rate" (or equivalent in Indonesian).
    - Verify that the "Time" value reflects the actual duration of the session.
- **Review Screen**:
    - Navigate to the first question and verify the "PREVIOUS" button is hidden/disabled.
    - Navigate to the last question and verify the "NEXT" button text changes to "FINISH" or "DONE".
    - Verify that the layout remains solid and aesthetic in both light and dark modes.
