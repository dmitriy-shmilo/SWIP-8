//
//  EmulatorKeyboardTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import XCTest
@testable import SWIP8

class EmulatorKeyboardTests: XCTestCase {

	let sut = Emulator()

	override func setUpWithError() throws {
		sut.reset()
	}

	func testSkipIfKeyPressedSkips() throws {
		let pc = sut.programCounter
		try sut.set(key: 2, pressed: true)
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2))
		try sut.execute(instruction: .makeSkipIfKeyPressed(registerX: 0))
		try sut.set(key: 2, pressed: false)

		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced")
	}

	func testSkipIfKeyPressedDoesntSkip() throws {
		let pc = sut.programCounter
		try sut.set(key: 3, pressed: true)
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2))
		try sut.execute(instruction: .makeSkipIfKeyPressed(registerX: 0))
		try sut.set(key: 3, pressed: false)

		XCTAssertEqual(sut.programCounter, pc, "PC should remain unaffected")
	}

	func testSkipIfKeyReleasedSkips() throws {
		let pc = sut.programCounter
		try sut.set(key: 3, pressed: true)
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2))
		try sut.execute(instruction: .makeSkipIfKeyNotPressed(registerX: 0))
		try sut.set(key: 3, pressed: false)

		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced")
	}

	func testSkipIfKeyReleasedDoesntSkip() throws {
		let pc = sut.programCounter
		try sut.set(key: 2, pressed: true)
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2))
		try sut.execute(instruction: .makeSkipIfKeyNotPressed(registerX: 0))
		try sut.set(key: 2, pressed: false)

		XCTAssertEqual(sut.programCounter, pc, "PC should remain unaffected")
	}

	func testWaitForKeyBlocks() throws {
		try sut.load(rom: [
			0xF1, 0x0A, // wait for key, reg 1
			0x62, 0xff // set reg 2 = 255
		])

		for _ in 0...10 {
			try sut.executeNextInstruction()
		}

		XCTAssertEqual(sut.registers[2], 0, "Register 2 should remain unaffected")
	}

	func testWaitForKeyProceeds() throws {
		try sut.load(rom: [
			0xF1, 0x0A, // wait for key, reg 1
			0x62, 0xff // set reg 2 = 255
		])

		try sut.set(key: 2, pressed: true)
		try sut.executeNextInstruction()
		try sut.executeNextInstruction()

		XCTAssertEqual(sut.registers[2], 0xff, "Register 2 should contain new value")
		XCTAssertEqual(sut.registers[1], 2, "Register 1 should contain pressed key index")
	}
}
