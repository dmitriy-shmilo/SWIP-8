//
//  SWIP8RandomTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 05.10.2021.
//

import XCTest
@testable import SWIP8

class SWIP8RandomTests: XCTestCase {

	var sut = Emulator()

	override func setUpWithError() throws {
		sut.reset()
	}
	
	func testRandom() throws {
		XCTAssertNoThrow(
			try sut.execute(instruction: .makeRandom(register: 1, mod: 0xff)),
			"Making a random number shouldn't throw"
		)
	}
	
	func testRandomClamps() throws {
		try sut.execute(instruction: .makeRandom(register: 1, mod: 0x0f))
		XCTAssertEqual(sut.registers[1] & 0xf0, 0, "Generated number should be between 0x00 and 0x0f")
	}
	
	func testRandomClampsToZero() throws {
		try sut.execute(instruction: .makeRandom(register: 1, mod: 0x00))
		XCTAssertEqual(sut.registers[1], 0, "Generated number should be 0x00")
	}
}
