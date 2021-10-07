//
//  EmulatorSkipTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 05.10.2021.
//

import XCTest
@testable import SWIP8

class EmulatorSkipTests: XCTestCase {

	let sut = Emulator()

	override func setUpWithError() throws {
		sut.reset()
	}

	func testSkipIfSkips() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSkipIf(register: 0, value: value))

		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced by one instruction")
	}

	func testSkipIfOutOfBounds() throws {
		let value: UInt8 = 123

		try sut.execute(instruction: .makeJump(address: 0x0fff))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))

		XCTAssertThrowsError(
			try sut.execute(instruction: .makeSkipIf(register: 0, value: value)),
			"Expected invalid PC error"
		)
	}

	func testSkipIfDoesntSkip() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSkipIf(register: 0, value: value + 1))

		XCTAssertEqual(sut.programCounter, pc, "PC should've been unaffected by a skip instruction")
	}

	func testSkipIfNotSkips() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSkipIfNot(register: 0, value: value + 1))

		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced by one instruction")
	}

	func testSkipIfNotOutOfBounds() throws {
		let value: UInt8 = 123

		try sut.execute(instruction: .makeJump(address: 0x0fff))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))

		XCTAssertThrowsError(
			try sut.execute(instruction: .makeSkipIfNot(register: 0, value: value + 1)),
			"Expected invalid PC error"
		)
	}

	func testSkipIfNotDoesntSkip() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSkipIfNot(register: 0, value: value))

		XCTAssertEqual(sut.programCounter, pc, "PC should've been unaffected by a skip instruction")
	}

	func testSkipIfRegisterSkips() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: value))
		try sut.execute(instruction: .makeSkipIfRegister(registerX: 0, registerY: 1))

		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced by one instruction")
	}

	func testSkipIfRegisterOutOfBounds() throws {
		let value: UInt8 = 123

		try sut.execute(instruction: .makeJump(address: 0x0fff))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: value))

		XCTAssertThrowsError(
			try sut.execute(instruction: .makeSkipIfRegister(registerX: 0, registerY: 1)),
			"Expected invalid PC error"
		)
	}

	func testSkipIfRegisterDoesntSkip() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: value + 1))
		try sut.execute(instruction: .makeSkipIfRegister(registerX: 0, registerY: 1))

		XCTAssertEqual(sut.programCounter, pc, "PC should've been unaffected by a skip instruction")
	}

	func testSkipIfNotRegisterSkips() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: value + 1))
		try sut.execute(instruction: .makeSkipIfNotRegister(registerX: 0, registerY: 1))

		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced by one instruction")
	}

	func testSkipIfNotRegisterOutOfBounds() throws {
		let value: UInt8 = 123

		try sut.execute(instruction: .makeJump(address: 0x0fff))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: value + 1))

		XCTAssertThrowsError(
			try sut.execute(instruction: .makeSkipIfNotRegister(registerX: 0, registerY: 1)),
			"Expected invalid PC error"
		)
	}

	func testSkipIfNotRegisterDoesntSkip() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: value))
		try sut.execute(instruction: .makeSkipIfNotRegister(registerX: 0, registerY: 1))

		XCTAssertEqual(sut.programCounter, pc, "PC should've been unaffected by a skip instruction")
	}

}
