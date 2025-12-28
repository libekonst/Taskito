//
//  StandardTimerPolicyTests.swift
//  TaskitoTests
//
//  Created by Konstantinos Liberopoulos on 28/12/24.
//

@testable import Taskito
import XCTest

final class StandardTimerPolicyTests: XCTestCase {
    var sut: StandardTimerPolicy!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = StandardTimerPolicy()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Limits Tests

    func testMinutesLimits_ReturnsCorrectRange() {
        // When
        let limits = sut.minutesLimits

        // Then
        XCTAssertEqual(limits.min, 0)
        XCTAssertEqual(limits.max, 99)
    }

    func testSecondsLimits_ReturnsCorrectRange() {
        // When
        let limits = sut.secondsLimits

        // Then
        XCTAssertEqual(limits.min, 0)
        XCTAssertEqual(limits.max, 59)
    }

    func testMinutesLimits_HasCorrectDigitCount() {
        // When
        let limits = sut.minutesLimits

        // Then
        XCTAssertEqual(limits.digitCount, 2)
    }

    func testSecondsLimits_HasCorrectDigitCount() {
        // When
        let limits = sut.secondsLimits

        // Then
        XCTAssertEqual(limits.digitCount, 2)
    }

    // MARK: - Formatting Tests

    func testToReadableTime_ZeroSeconds_ReturnsCorrectFormat() {
        // When
        let result = sut.toReadableTime(seconds: 0)

        // Then
        XCTAssertEqual(result, "00:00")
    }

    func testToReadableTime_OneMinute_ReturnsCorrectFormat() {
        // When
        let result = sut.toReadableTime(seconds: 60)

        // Then
        XCTAssertEqual(result, "01:00")
    }

    func testToReadableTime_TenMinutes_ReturnsCorrectFormat() {
        // When
        let result = sut.toReadableTime(seconds: 600)

        // Then
        XCTAssertEqual(result, "10:00")
    }

    func testToReadableTime_MaxDuration_ReturnsCorrectFormat() {
        // When - 99 minutes 59 seconds
        let result = sut.toReadableTime(seconds: 5999)

        // Then
        XCTAssertEqual(result, "99:59")
    }

    func testToReadableTime_MixedTime_FormatsCorrectly() {
        // When - 25 minutes 30 seconds
        let result = sut.toReadableTime(seconds: 1530)

        // Then
        XCTAssertEqual(result, "25:30")
    }

    func testToReadableTime_SingleDigitSeconds_PadsWithZero() {
        // When - 5 minutes 3 seconds
        let result = sut.toReadableTime(seconds: 303)

        // Then
        XCTAssertEqual(result, "05:03")
    }

    // MARK: - Formatter Tests

    func testMinutesFormatter_AcceptsValidMinimum() {
        // Given
        let formatter = sut.minutesFormatter as! NumberFormatter

        // When
        let result = formatter.number(from: "0")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.intValue, 0)
    }

    func testMinutesFormatter_AcceptsValidMaximum() {
        // Given
        let formatter = sut.minutesFormatter as! NumberFormatter

        // When
        let result = formatter.number(from: "99")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.intValue, 99)
    }

    func testSecondsFormatter_AcceptsValidMinimum() {
        // Given
        let formatter = sut.secondsFormatter as! NumberFormatter

        // When
        let result = formatter.number(from: "0")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.intValue, 0)
    }

    func testSecondsFormatter_AcceptsValidMaximum() {
        // Given
        let formatter = sut.secondsFormatter as! NumberFormatter

        // When
        let result = formatter.number(from: "59")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.intValue, 59)
    }

    func testMinutesFormatter_HasCorrectNumberStyle() {
        // Given
        let formatter = sut.minutesFormatter as! NumberFormatter

        // Then
        XCTAssertEqual(formatter.numberStyle, .none)
    }

    func testSecondsFormatter_HasCorrectNumberStyle() {
        // Given
        let formatter = sut.secondsFormatter as! NumberFormatter

        // Then
        XCTAssertEqual(formatter.numberStyle, .none)
    }
}
