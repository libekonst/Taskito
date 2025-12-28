# Taskito Testing Plan

**Status:** Phase 1 Week 1 Complete - 51 unit tests implemented and passing
**Priority:** Medium - Continue with Phase 1 Week 2-3 tests (SettingsStore, advanced CountdownStore, integration tests)

---

## Testing Strategy Overview

### Test Pyramid
1. **Unit Tests (70%)** - Fast, isolated, business logic
2. **Integration Tests (20%)** - Components working together
3. **UI Tests (10%)** - Critical user flows

### Test Framework
- **XCTest** (already configured)
- **@testable import Taskito** for internal access
- **XCUITest** for UI automation

---

## Phase 1: Unit Tests (High Priority)

### 1.1 CountdownStore Tests
**File:** `TaskitoTests/CountdownStoreTests.swift`
**Priority:** CRITICAL - Core timer business logic

#### Test Coverage:

**Timer State Management:**
- [x] `testStartNewTimer_ValidDuration_StartsTimer()`
- [x] `testStartNewTimer_ZeroDuration_AllowsZeroTimer()` (Note: Zero duration is allowed)
- [x] `testStartNewTimer_NegativeDuration_ReturnsInvalidDuration()`
- [x] `testStartNewTimer_WhileRunning_ReturnsTimerAlreadyRunning()`
- [x] `testStartNewTimer_WhilePaused_ReturnsTimerAlreadyRunning()`

**Timer Operations:**
- [x] `testTogglePlayPauseTimer_WhileRunning_PausesTimer()`
- [x] `testTogglePlayPauseTimer_WhilePaused_ResumesTimer()`
- [x] `testTogglePlayPauseTimer_WhileIdle_ReturnsNoActiveTimer()`
- [x] `testCancelTimer_WhileRunning_CancelsAndSetsStateToCancelled()`
- [x] `testCancelTimer_WhilePaused_CancelsSuccessfully()`
- [x] `testCancelTimer_WhileIdle_ReturnsNoActiveTimer()`
- [x] `testRestartTimer_ResetsToInitialDuration()` (covers PreservesInitialSecondsTotal)
- [x] `testRestartTimer_WhileIdle_ReturnsNoActiveTimer()`

**Time Manipulation:**
- [x] `testAddTime_PositiveSeconds_IncreasesSecondsTotal()`
- [x] `testAddTime_ZeroSeconds_ReturnsInvalidAmount()`
- [x] `testAddTime_NegativeSeconds_ReturnsInvalidAmount()`
- [x] `testAddTime_WhileIdle_ReturnsNoActiveTimer()`

**Timer Completion:**
- [ ] `testTimerCountdown_CompletesWhenSecondsElapsedReachesTotal()` (requires time mocking)
- [ ] `testTimerCompletion_CallsOnTimerCompletedHandler()` (requires time mocking)
- [ ] `testTimerCompletion_SetsStateToCompleted()` (requires time mocking)
- [x] `testSecondsRemaining_CalculatesCorrectly()`

**Edge Cases:**
- [x] `testStartNewTimer_MaxDuration_HandlesCorrectly()`
- [x] `testMultipleRestarts_MaintainsCorrectState()`
- [x] `testAddTime_DuringPausedTimer_UpdatesCorrectly()`

---

### 1.2 TimerPolicy Tests
**File:** `TaskitoTests/StandardTimerPolicyTests.swift`
**Priority:** HIGH - Validation and formatting

#### Test Coverage:

**Limits Validation:**
- [x] `testMinutesLimits_ReturnsCorrectRange()` // 0-99
- [x] `testSecondsLimits_ReturnsCorrectRange()` // 0-59
- [x] `testMinutesLimits_HasCorrectDigitCount()` // 2
- [x] `testSecondsLimits_HasCorrectDigitCount()` // 2

**Formatting:**
- [x] `testToReadableTime_ZeroSeconds_ReturnsCorrectFormat()` // "00:00"
- [x] `testToReadableTime_OneMinute_ReturnsCorrectFormat()` // "01:00"
- [x] `testToReadableTime_TenMinutes_ReturnsCorrectFormat()` // "10:00"
- [x] `testToReadableTime_MaxDuration_ReturnsCorrectFormat()` // "99:59"
- [x] `testToReadableTime_MixedTime_FormatsCorrectly()` // "25:30"
- [x] `testToReadableTime_SingleDigitSeconds_PadsWithZero()` // "05:03"

**Formatters:**
- [x] `testMinutesFormatter_AcceptsValidMinimum()`
- [x] `testMinutesFormatter_AcceptsValidMaximum()`
- [x] `testSecondsFormatter_AcceptsValidMinimum()`
- [x] `testSecondsFormatter_AcceptsValidMaximum()`
- [x] `testMinutesFormatter_HasCorrectNumberStyle()`
- [x] `testSecondsFormatter_HasCorrectNumberStyle()`

---

### 1.3 PresetTimersStore Tests
**File:** `TaskitoTests/PresetTimersStoreTests.swift`
**Priority:** MEDIUM - Preset management

#### Test Coverage:

**Initialization:**
- [x] `testInit_FirstLaunch_LoadsDefaults()`
- [x] `testInit_WithExistingData_LoadsFromStorage()`
- [x] `testInit_CorruptedData_FallsBackToDefaults()`

**CRUD Operations:**
- [x] `testAddPreset_AddsToPresets()`
- [x] `testAddPreset_SavesToStorage()`
- [x] `testUpdatePreset_UpdatesExistingPreset()`
- [x] `testUpdatePreset_NonExistentPreset_DoesNothing()`
- [x] `testRemovePreset_RemovesFromList()`
- [x] `testRemovePreset_SavesChanges()`
- [x] `testResetToDefaults_RestoresDefaultPresets()`

**Persistence:**
- [x] `testPresetPersistence_SurvivesReinitialization()`
- [x] `testPresetPersistence_HandlesEmptyData()`

---

### 1.4 SettingsStore Tests
**File:** `TaskitoTests/SettingsStoreTests.swift`
**Priority:** MEDIUM - Settings management

#### Test Coverage:

**Sound Settings:**
- [ ] `testSoundEnabled_DefaultsToTrue()`
- [ ] `testSoundEnabled_PersistsChanges()`

**Keyboard Shortcut Settings:**
- [ ] `testGlobalShortcutEnabled_DefaultsToTrue()`
- [ ] `testGlobalShortcutEnabled_PersistsChanges()`

**Startup Settings:**
- [ ] `testStartOnStartup_DefaultsToFalse()`
- [ ] `testStartOnStartup_SyncsWithSystemState()`
- [ ] `testStartOnStartup_HandlesLoginItemFailure()`
- [ ] `testStartOnStartup_RevertsOnError()`

**System Sync:**
- [ ] `testSyncWithSystemState_UpdatesFromSystem()`
- [ ] `testAppDidBecomeActive_SyncsState()`
- [ ] `testIsSyncingFlag_PreventsRecursiveUpdates()`

---

### 1.5 PresetTimer Model Tests
**File:** `TaskitoTests/PresetTimerTests.swift`
**Priority:** LOW - Simple model

#### Test Coverage:

- [ ] `testPresetTimer_Codable_EncodesCorrectly()`
- [ ] `testPresetTimer_Codable_DecodesCorrectly()`
- [ ] `testPresetTimer_Equatable_ComparesById()`
- [ ] `testDefaults_ContainsExpectedPresets()` // Pomodoro, Short Break, Long Break

---

### 1.6 AppStorageKeys Tests
**File:** `TaskitoTests/AppStorageKeysTests.swift`
**Priority:** LOW - Constants validation

#### Test Coverage:

- [ ] `testAppStorageKeys_AllKeysAreUnique()`
- [ ] `testAppStorageKeys_NoEmptyStrings()`
- [ ] `testSettingsKeys_FollowNamingConvention()` // "settings." prefix

---

## Phase 2: Integration Tests (Medium Priority)

### 2.1 Timer Lifecycle Integration Tests
**File:** `TaskitoTests/TimerLifecycleIntegrationTests.swift`
**Priority:** HIGH - End-to-end timer flows

#### Test Coverage:

**Complete Timer Flow:**
- [ ] `testCompleteTimerFlow_StartPauseResumeComplete()`
- [ ] `testCompleteTimerFlow_StartCancelRestart()`
- [ ] `testCompleteTimerFlow_StartAddTimeComplete()`

**Audio Integration:**
- [ ] `testTimerCompletion_TriggersAudioWhenEnabled()`
- [ ] `testTimerCompletion_NoAudioWhenDisabled()`

**Settings Integration:**
- [ ] `testSettingsChange_ReflectsInTimerBehavior()`

---

### 2.2 Preset & Timer Integration Tests
**File:** `TaskitoTests/PresetTimerIntegrationTests.swift`
**Priority:** MEDIUM

#### Test Coverage:

- [ ] `testPresetSelection_StartsTimerWithCorrectDuration()`
- [ ] `testPresetCreation_ValidatesAgainstTimerPolicy()`
- [ ] `testPresetUpdate_MaintainsConsistency()`

---

## Phase 3: UI Tests (Lower Priority)

### 3.1 Critical User Flows
**File:** `TaskitoUITests/CriticalFlowsUITests.swift`
**Priority:** MEDIUM - Core user journeys

#### Test Coverage:

**Timer Start Flow:**
- [ ] `testStartTimer_FromMenuBar_StartsCountdown()`
- [ ] `testStartTimer_FromGlobalShortcut_OpensQuickTimer()`
- [ ] `testStartTimer_WithPreset_UsesPresetDuration()`

**Timer Control Flow:**
- [ ] `testPauseTimer_DuringCountdown_PausesCorrectly()`
- [ ] `testResumeTimer_AfterPause_ResumesCorrectly()`
- [ ] `testCancelTimer_ShowsIdleState()`
- [ ] `testRestartTimer_ResetsToInitial()`

**Global Shortcut Flow:**
- [ ] `testGlobalShortcut_FirstPress_OpensQuickTimer()`
- [ ] `testGlobalShortcut_SecondPress_ClosesQuickTimer()`
- [ ] `testGlobalShortcut_WhileTimerRunning_ShowsRunningState()`

---

### 3.2 Settings UI Tests
**File:** `TaskitoUITests/SettingsUITests.swift`
**Priority:** LOW

#### Test Coverage:

- [ ] `testOpenSettings_DisplaysAllSections()`
- [ ] `testToggleSoundEnabled_UpdatesImmediately()`
- [ ] `testToggleGlobalShortcut_UpdatesImmediately()`
- [ ] `testToggleStartOnStartup_UpdatesSystem()`

---

### 3.3 Preset Management UI Tests
**File:** `TaskitoUITests/PresetManagementUITests.swift`
**Priority:** LOW

#### Test Coverage:

- [ ] `testCreatePreset_AddsToList()`
- [ ] `testEditPreset_UpdatesValues()`
- [ ] `testDeletePreset_RemovesFromList()`
- [ ] `testResetPresets_RestoresDefaults()`

---

## Phase 4: Performance & Edge Cases

### 4.1 Performance Tests
**File:** `TaskitoTests/PerformanceTests.swift`

- [ ] `testTimerCountdown_PerformanceUnder1ms()`
- [ ] `testPresetLoading_PerformanceUnder10ms()`
- [ ] `testSettingsRead_PerformanceUnder5ms()`

### 4.2 Concurrency Tests
**File:** `TaskitoTests/ConcurrencyTests.swift`

- [ ] `testMultipleTimerOperations_ThreadSafe()`
- [ ] `testSettingsUpdate_DuringTimerRunning_NoRaceCondition()`

---

## Implementation Priority

### Immediate (Week 1) - ✅ COMPLETE
1. ✅ CountdownStore basic tests (start, pause, cancel, restart, add time)
2. ✅ CountdownStore edge cases (max duration, multiple restarts, paused timer updates)
3. ✅ TimerPolicy validation and formatting tests
4. ✅ PresetTimersStore CRUD and persistence tests

**Test Summary:**
- CountdownStoreTests: 21 tests (18 implemented, 3 require time mocking)
- StandardTimerPolicyTests: 17 tests (all implemented)
- PresetTimersStoreTests: 13 tests (all implemented)
- **Total: 51 tests passing**

### Short-term (Week 2-3)
4. ⏸️ CountdownStore timer completion tests (requires time mocking framework)
5. ⏸️ SettingsStore tests (sound, shortcuts, startup settings)
6. ⏸️ Timer lifecycle integration tests

### Medium-term (Month 1)
7. ⏸️ UI tests for critical flows
8. ⏸️ Audio integration tests
9. ⏸️ Performance tests

### Long-term (Ongoing)
10. ⏸️ Additional UI tests
11. ⏸️ Concurrency tests
12. ⏸️ Regression tests as bugs are found

---

## Test Coverage Goals

- **Phase 1 Complete:** 60% code coverage
- **Phase 2 Complete:** 75% code coverage
- **Phase 3 Complete:** 85% code coverage

---

## Testing Infrastructure Needed

### Tools & Setup
- [ ] Configure code coverage reporting in Xcode
- [ ] Set up CI/CD for automated test runs (GitHub Actions)
- [ ] Add test execution to pre-commit hooks
- [ ] Configure test timeout settings

### Mock Objects Needed
- [ ] Mock TimerPolicy for testing with different limits
- [ ] Mock LoginItemManager for testing without system changes
- [ ] Mock AudioPlayer for testing without sound
- [ ] Mock NSApp for window testing

### Test Utilities
- [ ] Test helpers for creating preset timers
- [ ] Test helpers for advancing time in tests
- [ ] Assertion helpers for Result types
- [ ] Helpers for cleaning UserDefaults between tests

---

## Notes

- Use `@MainActor` where needed for SwiftUI tests
- Clean UserDefaults before each test to ensure isolation
- Use `XCTUnwrap` instead of force unwrapping
- Group related tests with `// MARK:` comments
- Add performance baselines for regression detection
- Consider snapshot testing for UI components (optional)

---

## Example Test Structure

```swift
@testable import Taskito
import XCTest

final class CountdownStoreTests: XCTestCase {
    var sut: CountdownStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = CountdownStore()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Start Timer Tests

    func testStartNewTimer_ValidDuration_StartsTimer() {
        // Given
        let minutes = 25
        let seconds = 0

        // When
        let result = sut.startNewTimer(minutes: minutes, seconds: seconds)

        // Then
        XCTAssertEqual(result, .success(()))
        XCTAssertEqual(sut.timerState, .running)
        XCTAssertEqual(sut.secondsTotal, 1500)
    }

    func testStartNewTimer_ZeroDuration_ReturnsInvalidDuration() {
        // Given
        let minutes = 0
        let seconds = 0

        // When
        let result = sut.startNewTimer(minutes: minutes, seconds: seconds)

        // Then
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got success")
            return
        }
        XCTAssertEqual(error, .invalidDuration)
        XCTAssertEqual(sut.timerState, .idle)
    }
}
```
