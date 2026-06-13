# Randomize Exam Questions while Preserving Section Order

Refactor the exam question loading logic to randomize questions within each section while strictly maintaining the "Language Knowledge" then "Reading" sequence.

## Proposed Changes

### Simulation Feature

#### [screen_simulation_test.dart](file:///C:/Users/ahmad/StudioProjects/miraiku/lib/features/simulation/screen_simulation_test.dart)

- **Initialization Logic**: Update `initState` to perform the following exactly once:
    1. Filter `SimulationData.n5Questions` into `languageKnowledgeList` and `readingList`.
    2. Call `.shuffle()` on both lists independently.
    3. Concatenate them: `_questions = [...languageKnowledgeList, ...readingList]`.
    4. Recalculate totals (`_languageTotal`, `_readingTotal`) based on the new list.

## Verification Plan

### Manual Verification
- **Shuffling Consistency**:
    - Start a new simulation and note the first few questions.
    - Exit and start another simulation. Verify that the question order within sections has changed.
- **Section Order**:
    - Navigate through the exam (or use debug logs) to verify that all "Language Knowledge" questions appear before any "Reading" questions.
- **Total Counts**:
    - Verify that the progress bar and final results still reflect the correct total number of questions for each section.
