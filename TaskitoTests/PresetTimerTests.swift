//
//  PresetTimerTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 29/12/24.
//

@testable import Taskito
import XCTest

final class PresetTimerTests: XCTestCase {
    // MARK: - Codable Tests

    func testPresetTimer_Codable_EncodesCorrectly() throws {
        // Given
        let preset = PresetTimer(
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!,
            name: "Test Timer",
            minutes: 25,
            seconds: 30
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(preset)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["name"] as? String, "Test Timer")
        XCTAssertEqual(json?["minutes"] as? Int, 25)
        XCTAssertEqual(json?["seconds"] as? Int, 30)
        XCTAssertEqual(json?["id"] as? String, "12345678-1234-1234-1234-123456789012")
    }

    func testPresetTimer_Codable_DecodesCorrectly() throws {
        // Given
        let json = """
        {
            "id": "12345678-1234-1234-1234-123456789012",
            "name": "Decoded Timer",
            "minutes": 10,
            "seconds": 45
        }
        """
        let data = json.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let preset = try decoder.decode(PresetTimer.self, from: data)

        // Then
        XCTAssertEqual(preset.id, UUID(uuidString: "12345678-1234-1234-1234-123456789012"))
        XCTAssertEqual(preset.name, "Decoded Timer")
        XCTAssertEqual(preset.minutes, 10)
        XCTAssertEqual(preset.seconds, 45)
    }

    // MARK: - Equatable Tests

    func testPresetTimer_Equatable_ComparesAllFields() {
        // Given - Two presets with identical values
        let sharedId = UUID()
        let preset1 = PresetTimer(id: sharedId, name: "Timer 1", minutes: 10, seconds: 30)
        let preset2 = PresetTimer(id: sharedId, name: "Timer 1", minutes: 10, seconds: 30)

        // Then - Should be equal (all fields match)
        XCTAssertEqual(preset1, preset2, "Presets with identical fields should be equal")

        // Given - Two presets with same ID but different name
        let preset3 = PresetTimer(id: sharedId, name: "Timer 1", minutes: 10, seconds: 0)
        let preset4 = PresetTimer(id: sharedId, name: "Timer 2", minutes: 10, seconds: 0)

        // Then - Should not be equal (different name)
        XCTAssertNotEqual(preset3, preset4, "Presets with different names should not be equal")

        // Given - Two presets with different IDs but same other values
        let preset5 = PresetTimer(id: UUID(), name: "Timer", minutes: 10, seconds: 0)
        let preset6 = PresetTimer(id: UUID(), name: "Timer", minutes: 10, seconds: 0)

        // Then - Should not be equal (different IDs)
        XCTAssertNotEqual(preset5, preset6, "Presets with different IDs should not be equal")
    }

    // MARK: - Defaults Tests

    func testDefaults_ContainsExpectedPresets() {
        // When
        let defaults = PresetTimer.defaults

        // Then - Should have 3 presets
        XCTAssertEqual(defaults.count, 3, "Should have 3 default presets")

        // Then - Should contain Pomodoro
        let pomodoro = defaults.first { $0.name == "Pomodoro" }
        XCTAssertNotNil(pomodoro, "Should contain Pomodoro preset")
        XCTAssertEqual(pomodoro?.minutes, 25)
        XCTAssertEqual(pomodoro?.seconds, 0)

        // Then - Should contain Short Break
        let shortBreak = defaults.first { $0.name == "Short Break" }
        XCTAssertNotNil(shortBreak, "Should contain Short Break preset")
        XCTAssertEqual(shortBreak?.minutes, 5)
        XCTAssertEqual(shortBreak?.seconds, 0)

        // Then - Should contain Long Break
        let longBreak = defaults.first { $0.name == "Long Break" }
        XCTAssertNotNil(longBreak, "Should contain Long Break preset")
        XCTAssertEqual(longBreak?.minutes, 15)
        XCTAssertEqual(longBreak?.seconds, 0)
    }

    // MARK: - Computed Property Tests

    func testTotalSeconds_CalculatesCorrectly() {
        // Given
        let preset1 = PresetTimer(name: "Test 1", minutes: 5, seconds: 30)
        let preset2 = PresetTimer(name: "Test 2", minutes: 0, seconds: 45)
        let preset3 = PresetTimer(name: "Test 3", minutes: 10, seconds: 0)

        // Then
        XCTAssertEqual(preset1.totalSeconds, 330, "5 minutes 30 seconds = 330 seconds")
        XCTAssertEqual(preset2.totalSeconds, 45, "0 minutes 45 seconds = 45 seconds")
        XCTAssertEqual(preset3.totalSeconds, 600, "10 minutes 0 seconds = 600 seconds")
    }
}
