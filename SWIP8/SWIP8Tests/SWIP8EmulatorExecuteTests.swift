//
//  SWIP8EmulatorTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import XCTest
@testable import SWIP8

class SWIP8EmulatorExecuteTests: XCTestCase {

	var sut = Emulator()

    override func setUpWithError() throws {
		sut.reset()
    }

	func testJump() throws {
		let address: UInt16 = 0x0ff0

		try sut.execute(instruction: .makeJump(address: address))
		XCTAssertEqual(sut.programCounter, address, "PC should point to address after jump")
		XCTAssertEqual(sut.stack.count, 0, "Expected call stack to remain empty after jump")
	}
	
	func testBCD() throws {
		let value: UInt8 = 123
		let address: UInt16 = 0x0200

		try sut.execute(instruction: .makeSetIndex(address: address))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		try sut.execute(instruction: .makeBCD(registerX: 0))
		
		XCTAssertEqual(sut.memory[address], 1)
		XCTAssertEqual(sut.memory[address + 1], 2)
		XCTAssertEqual(sut.memory[address + 2], 3)
	}
}
