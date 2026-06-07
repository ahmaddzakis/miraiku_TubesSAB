# Implementation Reference Guide

## Quick Start Guide for Testing

### Test Case 1: Mark a Character as Learned (Basic Flow)

1. **Open Kana Screen** → Navigate to `lib/features/kana/screen_kana.dart`

2. **Tap a Hiragana Card** (e.g., 'あ')
   - Calls: `_onKanaTapped(item, dataList)`
   - Which calls: `GameManager.markCharacterAsLearned('hiragana', 'あ')`
   - Expected Result:
     - Card highlights (border color changes to #C6653B)
     - Card background changes to light tan (#F7E6D4) or dark overlay
     - Progress counter increments: "0 / 104 SELESAI" → "1 / 104 SELESAI"
     - XP unchanged (milestone at 10 characters)

3. **Repeat 9 More Times** (mark 9 more hiragana characters)
   - Expected Result on 10th character:
     - Progress counter shows "10 / 104 SELESAI"
     - XP increases by 50 (shown wherever XP is displayed in app)

4. **Mark 36 More Characters** (total 46 = gojuon complete)
   - Expected Result on 46th character:
     - Progress counter shows "46 / 104 SELESAI"
     - XP increases by additional 200
     - Total XP = 50 (from 10) + 200 (from 46) = 250 XP

---

### Test Case 2: Popup Navigation

1. **Tap a Card** → Opens stroke-learning popup

2. **Click "Next" Button**
   - Calls: `goToNext()`
   - Which calls: `GameManager.markCharacterAsLearned('hiragana', nextChar)`
   - Expected Result:
     - Current character marked as learned
     - Counter increments
     - Popup shows next character

3. **Click "Prev" Button**
   - Calls: `goToPrev()`
   - Which calls: `GameManager.markCharacterAsLearned('hiragana', prevChar)`
   - Expected Result:
     - Current character marked as learned (if not already)
     - Counter increments
     - Popup shows previous character

---

### Test Case 3: Tab Switching

1. **In Hiragana Tab** → Mark 5 characters as learned

2. **Switch to Katakana Tab**
   - Expected Result:
     - All cards are unmarked (Katakana is separate list)
     - Progress counter resets: "0 / 104 SELESAI"

3. **Mark 5 Katakana Characters**

4. **Switch back to Hiragana Tab**
   - Expected Result:
     - Original 5 Hiragana characters still marked
     - Progress counter shows: "5 / 104 SELESAI"

5. **Switch to Kanji Tab**
   - Expected Result:
     - No cards marked (separate list)
     - Progress counter shows: "0 / 68 SELESAI" (kanji has 68 total)

---

### Test Case 4: Cloud Sync & Persistence

#### Offline Scenario

1. **Mark Characters (Offline)**
   - Device offline → Mark 5 Hiragana characters
   - Expected: Progress updates locally ✓

2. **Go Online**
   - Expected: Data syncs to Supabase user metadata under:
     - `learned_hiragana` (array of 5 characters)

#### Multi-Device Scenario

1. **Login on Device A** → Mark 10 Hiragana
   - XP = 50
   - `learned_hiragana` in cloud = ['あ', 'い', 'う', 'え', 'お', 'か', 'き', 'く', 'け', 'こ']

2. **Logout on Device A**

3. **Login on Device B**
   - Expected Result:
     - Progress restored from cloud
     - Grid shows 10 marked characters
     - Counter shows "10 / 104 SELESAI"
     - XP = 50

---

### Test Case 5: Dark Mode Toggle

1. **In Dark Mode** → Mark some characters

2. **Toggle to Light Mode**
   - Expected Result:
     - Learned cards show light tan background (#F7E6D4)
     - Progress still shows marked count
     - Cannot lose progress

3. **Toggle back to Dark Mode**
   - Expected Result:
     - Learned cards show dark overlay
     - Progress persists

---

### Test Case 6: Header Stickiness

1. **Open Kana Screen** in any tab

2. **Scroll Down** (on the grid)
   - Expected Result:
     - Header (tabs + progress banner) stays at top
     - Only grid content scrolls
     - Banner does NOT move down

3. **Scroll Up**
   - Expected Result:
     - Can scroll back to top
     - Header remains in place

---

## Database/Storage Verification

### SharedPreferences Keys (Local)

```
learned_hiragana_list: ['あ', 'い', 'う', ...]  (stringList)
learned_katakana_list: ['ア', 'イ', 'ウ', ...]  (stringList)
learned_kanji_list: ['一', '二', '三', ...]      (stringList)
```

### Supabase user metadata (Cloud)

```json
{
  "learned_hiragana": ["あ", "い", "う", ...],
  "learned_katakana": ["ア", "イ", "ウ", ...],
  "learned_kanji": ["一", "二", "三", ...],
  "gm_xp": 50
}
```

---

## Debug Logging

Enable debug logging to verify execution:

```dart
// In pubspec.yaml or AndroidManifest.xml, enable debug mode
// Then check console for these logs:

// When character is marked as learned:
"DEBUG: [hiragana] Character marked as learned: 'あ'. Total count: 1"

// When XP milestone is reached:
"DEBUG: XP bertambah +50. Total sekarang: 50"

// When syncing to cloud:
"DEBUG: State updated. XP: 50, Hearts: 5"
```

---

## Common Issues & Solutions

### Issue: Card doesn't highlight after tap

**Cause:** ValueNotifier listener not triggered
```dart
// Verify in code:
notifier.value = newList;  // Must reassign, not mutate
```
**Solution:** Already implemented ✓

### Issue: Progress counter doesn't update

**Cause:** ValueListenableBuilder not rebuilding
```dart
// Check that correct ValueNotifier is used:
ValueListenableBuilder(
  valueListenable: globalLearnedHiragana,  // Must match script type
  builder: (context, learnedList, _) { ... }
)
```
**Solution:** Already correctly implemented ✓

### Issue: XP not increasing

**Cause:** addXP() call failing or cloud sync issue
```dart
// Check debug logs for:
"ERROR in markCharacterAsLearned: ..."
```
**Solution:** Check Supabase auth status and network

### Issue: Scroll doesn't work

**Cause:** SingleChildScrollView missing or nested incorrectly
**Solution:** Already fixed in refactored layout ✓

---

## Performance Notes

- ✅ ValueNotifier updates are efficient (only affected widgets rebuild)
- ✅ GridView is wrapped in NeverScrollableScrollPhysics for performance
- ✅ AnimatedSwitcher uses minimal duration (400ms)
- ✅ Cloud sync is async/non-blocking

---

## Security Notes

- ✅ Supabase keys are already in `main.dart` (external configuration)
- ✅ User metadata is encrypted in transit (Supabase SSL)
- ✅ No sensitive data stored in SharedPreferences (only learned characters)
- ✅ Anti-rollback logic prevents XP manipulation

---

End of Reference Guide

