//
//  EmulatorLoadTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import XCTest
@testable import SWIP8

class EmulatorLoadTests: XCTestCase {

	let sut = Emulator()

	override func setUpWithError() throws {
		sut.reset()
	}

	func testLoad() throws {
		let rom: [UInt8] = [0x01, 0x02, 0x03, 0x04]
		let memorySize = sut.memory.count
		try sut.load(rom: rom)
		XCTAssertEqual(sut.memory.count, memorySize, "Loading ROM shouldn't affect memory size")
		XCTAssertEqual(sut.peekInstruction(), Instruction(a: 0x01, b: 0x02), "Emulator should point to the first instruction")
	}

	func testLoadEmpty() throws {
		let rom: [UInt8] = []
		XCTAssertThrowsError(try sut.load(rom: rom), "Loading an empty rom should be an error")
	}

	func testLoadOdd() throws {
		let rom: [UInt8] = [0x01, 0x02, 0x03]
		try sut.load(rom: rom)

		XCTAssertEqual(
			sut.memory[sut.programCounter + 2],
			0x03,
			"Last odd byte should be loaded into memory"
		)

		XCTAssertEqual(
			sut.memory[sut.programCounter + 3],
			0x00,
			"Last instruction should be padded with zero"
		)
	}

	func testLoadExceedingMemory() throws {
		let availableMemory = sut.memory.count
		let rom = [UInt8](repeating: 0x01, count: availableMemory)
		XCTAssertThrowsError(try sut.load(rom: rom), "Loading a rom, which exceeds available memory, shoud be an error")
	}

	func testLoadExactlyFitting() throws {
		let availableMemory = sut.memory.count
		var rom = [UInt8](repeating: 0x01, count: availableMemory - Int(Emulator.ReservedMemorySize))
		rom[rom.count - 1] = 0x02
		try sut.load(rom: rom)
		XCTAssertEqual(sut.memory.last ?? 0, 0x02, "Last byte of loaded memory should be preserved")
	}

	func testLoadEmptyString() throws {
		let rom = ""
		XCTAssertThrowsError(try sut.load(string: rom), "Loading an empty string should be an error")
	}

	func testLoadString() throws {
		let rom = "01020304"
		let pc = sut.programCounter
		try sut.load(string: rom)

		for (i, byte) in [UInt8](arrayLiteral: 0x01, 0x02, 0x03, 0x04).enumerated() {
			XCTAssertEqual(sut.memory[pc + UInt16(i)], byte, "\(i) program byte should be \(byte)")
		}
	}

	func testLoadInvalidCharacterString() throws {
		let rom = "0102030g"
		XCTAssertThrowsError(try sut.load(string: rom), "Loading string with an invalid character should throw an error")
	}

	func testLoadInvalidDigitCountString() throws {
		let rom = "0102030"
		XCTAssertThrowsError(try sut.load(string: rom), "Loading string with odd number of digits should throw an error")
	}

	func testLoadInvalidByteCountString() throws {
		let rom = "010203"
		try sut.load(string: rom)

		XCTAssertEqual(
			sut.memory[sut.programCounter + 2],
			0x03,
			"Last odd byte should be loaded into memory"
		)

		XCTAssertEqual(
			sut.memory[sut.programCounter + 3],
			0x00,
			"Last instruction should be padded with zero"
		)
	}

	func testLoadWhitespaceAndNewlinesString() throws {
		let rom = "\t0102 0304\n\t0102 0304\n"
		let pc = sut.programCounter
		try sut.load(string: rom)

		for (i, byte) in [UInt8](
			arrayLiteral: 0x01, 0x02, 0x03, 0x04, 0x01, 0x02, 0x03, 0x04
		).enumerated() {
			XCTAssertEqual(sut.memory[pc + UInt16(i)], byte, "\(i) program byte should be \(byte)")
		}
	}

	func testLoadInstruction() throws {
		try sut.load(instructions: .makeWaitForKey(registerX: 0), .makeReturn())
		for (i, byte) in [UInt8](
			arrayLiteral: 0xf0, 0x0a, 0x00, 0xee
		).enumerated() {
			XCTAssertEqual(sut.memory[sut.programCounter + UInt16(i)], byte, "\(i) program byte should be \(byte)")
		}
	}
}
