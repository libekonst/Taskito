# Test Hygiene Guide

## Overview

This document outlines best practices for maintaining clean, isolated tests in Taskito.

---

## Test Isolation Guarantees

### What We Ensure

✅ **Each test starts with clean UserDefaults** - setUp cleans before every test
✅ **Tests don't depend on execution order** - Cleanup in setUp handles crashed tests
✅ **Manual app data doesn't affect tests** - setUp removes any existing data
✅ **Tests clean up after themselves** - tearDown prevents pollution

### What's Shared

⚠️ **UserDefaults.standard** - Tests and production app share the same storage
- **Mitigation**: Don't run the app while tests are running
- **Impact**: Low risk in practice

---

## Using TestHelpers

### For Single Key Cleanup

```swift
override func setUpWithError() throws {
    try super.setUpWithError()

    // Clean before test (ensures isolation)
    TestHelpers.cleanUserDefaults(key: AppStorageKeys.presetTimers)

    sut = PresetTimersStore()
}

override func tearDownWithError() throws {
    sut = nil

    // Clean after test (prevents pollution)
    TestHelpers.cleanUserDefaults(key: AppStorageKeys.presetTimers)

    try super.tearDownWithError()
}
```

### For Multiple Keys Cleanup

```swift
override func setUpWithError() throws {
    try super.setUpWithError()

    // Clean multiple keys at once
    TestHelpers.cleanUserDefaults(keys: [
        AppStorageKeys.Settings.soundEnabled,
        AppStorageKeys.Settings.globalShortcutEnabled,
        AppStorageKeys.Settings.startOnStartup
    ])

    sut = SettingsStore(loginItemManager: mockLoginItemManager)
}
```

### For Complete App Cleanup

```swift
override func setUpWithError() throws {
    try super.setUpWithError()

    // Clean ALL app keys (use sparingly)
    TestHelpers.cleanUserDefaults()

    // ... test setup
}
```

---

## Best Practices

### ✅ DO

1. **Always clean in setUp** - Most important for isolation
   ```swift
   override func setUpWithError() throws {
       TestHelpers.cleanUserDefaults(key: myKey)  // ← Critical!
       sut = MyStore()
   }
   ```

2. **Always clean in tearDown** - Good citizen behavior
   ```swift
   override func tearDownWithError() throws {
       sut = nil
       TestHelpers.cleanUserDefaults(key: myKey)  // ← Polite!
   }
   ```

3. **Use TestHelpers consistently** - Don't mix approaches
   ```swift
   // ✅ Good
   TestHelpers.cleanUserDefaults(key: AppStorageKeys.presetTimers)

   // ❌ Avoid (use TestHelpers instead)
   UserDefaults.standard.removeObject(forKey: AppStorageKeys.presetTimers)
   ```

4. **Document which keys your test uses**
   ```swift
   /// Tests PresetTimersStore functionality
   /// UserDefaults keys used: AppStorageKeys.presetTimers
   final class PresetTimersStoreTests: XCTestCase {
   ```

### ❌ DON'T

1. **Don't skip cleanup** - Every store test needs it
   ```swift
   // ❌ Bad - no cleanup
   override func setUpWithError() throws {
       sut = PresetTimersStore()  // Will see old data!
   }
   ```

2. **Don't forget to add new keys** - Update TestHelpers.allAppStorageKeys
   ```swift
   // If you add a new @AppStorage key:
   @AppStorage("newKey") var newSetting: Bool = false

   // Add it to TestHelpers.allAppStorageKeys:
   static let allAppStorageKeys: [String] = [
       // ...
       "newKey",  // ← Don't forget!
   ]
   ```

3. **Don't rely on tearDown only** - setUp is critical
   ```swift
   // ❌ Bad - only tearDown
   override func tearDownWithError() throws {
       TestHelpers.cleanUserDefaults(key: myKey)
   }

   // ✅ Good - both setUp and tearDown
   override func setUpWithError() throws {
       TestHelpers.cleanUserDefaults(key: myKey)  // ← Essential!
   }
   override func tearDownWithError() throws {
       TestHelpers.cleanUserDefaults(key: myKey)  // ← Nice to have
   }
   ```

---

## Checklist for New Tests

When writing a test that uses UserDefaults/AppStorage:

- [ ] Identify which AppStorage keys are used
- [ ] Add cleanup in `setUpWithError()` using TestHelpers
- [ ] Add cleanup in `tearDownWithError()` using TestHelpers
- [ ] If new key, add to `TestHelpers.allAppStorageKeys`
- [ ] Verify test passes in isolation: `xcodebuild test -only-testing:MyTest`
- [ ] Verify test passes when run twice: Run test → Run again
- [ ] Document which keys are used in test class comment

---

## Examples

### Example 1: Testing a Store with Single Key

```swift
final class MyStoreTests: XCTestCase {
    var sut: MyStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        TestHelpers.cleanUserDefaults(key: AppStorageKeys.myKey)
        sut = MyStore()
    }

    override func tearDownWithError() throws {
        sut = nil
        TestHelpers.cleanUserDefaults(key: AppStorageKeys.myKey)
        try super.tearDownWithError()
    }

    func testMyFeature() {
        // Test is isolated - starts with clean UserDefaults
        XCTAssertEqual(sut.value, expectedDefault)
    }
}
```

### Example 2: Testing Multiple Stores

```swift
final class IntegrationTests: XCTestCase {
    var presetStore: PresetTimersStore!
    var settingsStore: SettingsStore!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Clean all keys used by both stores
        TestHelpers.cleanUserDefaults(keys: [
            AppStorageKeys.presetTimers,
            AppStorageKeys.Settings.soundEnabled,
            AppStorageKeys.Settings.startOnStartup
        ])

        presetStore = PresetTimersStore()
        settingsStore = SettingsStore(loginItemManager: mockManager)
    }

    override func tearDownWithError() throws {
        presetStore = nil
        settingsStore = nil

        TestHelpers.cleanUserDefaults(keys: [
            AppStorageKeys.presetTimers,
            AppStorageKeys.Settings.soundEnabled,
            AppStorageKeys.Settings.startOnStartup
        ])

        try super.tearDownWithError()
    }
}
```

---

## Troubleshooting

### "My test passes alone but fails when run with others"

**Cause**: Insufficient cleanup - test is seeing data from previous tests

**Fix**: Add cleanup in setUp:
```swift
override func setUpWithError() throws {
    TestHelpers.cleanUserDefaults(key: myKey)  // Add this!
    sut = MyStore()
}
```

### "My test affects the running app"

**Cause**: Tests write to UserDefaults.standard (same as production)

**Mitigation**:
- Don't run app while tests are running
- Always use cleanup in setUp/tearDown

**Advanced Solution** (only if needed):
- Refactor stores to accept UserDefaults parameter
- Use test-specific UserDefaults suite in tests

### "I added a new key but tests are flaky"

**Cause**: Forgot to add key to TestHelpers.allAppStorageKeys

**Fix**:
1. Add key to `TestHelpers.allAppStorageKeys`
2. Use `TestHelpers.cleanUserDefaults()` in your test

---

## Performance Impact

Cleaning UserDefaults is **extremely fast** (~0.001 seconds per key):

```swift
// This overhead is negligible
TestHelpers.cleanUserDefaults(keys: [key1, key2, key3])
// ~0.003 seconds total
```

**Always prefer cleanliness over micro-optimizations.**

---

## Summary

✅ **Always clean in setUp** - Ensures isolation
✅ **Always clean in tearDown** - Prevents pollution
✅ **Use TestHelpers consistently** - Centralized approach
✅ **Document keys used** - Makes tests maintainable

**Result**: Fast, reliable, isolated tests! 🎉
