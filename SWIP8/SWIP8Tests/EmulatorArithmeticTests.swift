//
//  EmulatorArithmeticTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import XCTest
@testable import SWIP8

class EmulatorArithmeticTests: XCTestCase {

	let sut = Emulator()
	
    override func setUpWithError() throws {
		sut.reset()
    }

	func testCopy() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 11))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 22))
		try sut.execute(instruction: .makeCopyRegister(registerX: 0, from: 1))
		XCTAssertEqual(sut.registers[0], 22, "Register 0 should receive new value")
		XCTAssertEqual(sut.registers[1], 22, "Register 1 should remain unaffected")
	}
	
	func testOr() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b0101))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b0110))
		try sut.execute(instruction: .makeOr(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b0111, "Register 0 should be equal to binary OR of 0b0101 and 0b0110")
		XCTAssertEqual(sut.registers[1], 0b0110, "Register 1 should remain unaffected")
	}
	
	func testAnd() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b0101))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b0110))
		try sut.execute(instruction: .makeAnd(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b0100, "Register 0 should be equal to binary AND of 0b0101 and 0b0110")
		XCTAssertEqual(sut.registers[1], 0b0110, "Register 1 should remain unaffected")
	}
	
	func testXor() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b0101))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b0110))
		try sut.execute(instruction: .makeXor(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b0011, "Register 0 should be equal to binary XOR of 0b0101 and 0b0110")
		XCTAssertEqual(sut.registers[1], 0b0110, "Register 1 should remain unaffected")
	}
	
	func testAdd() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 11))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 22))
		try sut.execute(instruction: .makeAdd(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 33, "Register 0 should be equal to the sum of both registers")
		XCTAssertEqual(sut.registers[1], 22, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 0, "Register F should remain zero")
	}
	
	func testAddOverflow() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 250))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 250))
		try sut.execute(instruction: .makeAdd(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], UInt8(250) &+ UInt8(250), "Register 0 should be equal to the sum of both registers, wrapped around")
		XCTAssertEqual(sut.registers[1], 250, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 1, "Register F should be set to 1 due to overflow")
	}
	
	func testSubtract() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 200))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 50))
		try sut.execute(instruction: .makeSubtract(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 150, "Register 0 should be equal to the difference between register 0 and 1")
		XCTAssertEqual(sut.registers[1], 50, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 1, "Register F should be set to 1 due to no underflow")
	}
	
	func testSubtractUnderflow() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 50))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 60))
		try sut.execute(instruction: .makeSubtract(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 246, "Register 0 should be equal to the difference between register 0 and 1 with wrapping")
		XCTAssertEqual(sut.registers[1], 60, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 0, "Register F should be set to 0 due to underflow")
	}
	
	func testReverseSubtract() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 50))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 200))
		try sut.execute(instruction: .makeReverseSubtract(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 150, "Register 0 should be equal to the difference between register 1 and 0")
		XCTAssertEqual(sut.registers[1], 200, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 1, "Register F should be set to 1 due to no underflow")
	}
	
	func testReverseSubtractUnderflow() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 60))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 50))
		try sut.execute(instruction: .makeReverseSubtract(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 246, "Register 0 should be equal to the difference between register 1 and 0 with wrapping")
		XCTAssertEqual(sut.registers[1], 50, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 0, "Register F should be set to 0 due to underflow")
	}
	
	func testShiftRightOutOne() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b0011))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b0101))
		try sut.execute(instruction: .makeShiftRight(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b0010, "Register 0 should be equal to register 1 shifted right once")
		XCTAssertEqual(sut.registers[1], 0b0101, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 1, "Register F should contain shifted out bit")
	}
	
	func testShiftRightOutZero() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b0011))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b0100))
		try sut.execute(instruction: .makeShiftRight(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b0010, "Register 0 should be equal to register 1 shifted right once")
		XCTAssertEqual(sut.registers[1], 0b0100, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 0, "Register F should contain shifted out bit")
	}
	
	func testShiftRightInPlace() throws {
		// FIXME: there should be an option to shift VX in place
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b0011))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b0101))
		try sut.execute(instruction: .makeShiftRight(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b0001, "Register 0 should be equal to register 0 shifted right once")
		XCTAssertEqual(sut.registers[1], 0b0101, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 1, "Register F should contain shifted out bit")
	}
	
	func testShiftLeftOutOne() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b0011_0000))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b1101_0000))
		try sut.execute(instruction: .makeShiftLeft(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b1010_0000, "Register 0 should be equal to register 1 shifted right once")
		XCTAssertEqual(sut.registers[1], 0b1101_0000, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 1, "Register F should contain shifted out bit")
	}
	
	func testShiftLeftOutZero() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b0011_0000))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b0101_0000))
		try sut.execute(instruction: .makeShiftLeft(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b1010_0000, "Register 0 should be equal to register 1 shifted right once")
		XCTAssertEqual(sut.registers[1], 0b0101_0000, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 0, "Register F should contain shifted out bit")
	}
	
	func testShiftLeftInPlace() throws {
		// FIXME: there should be an option to shift VX in place
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0b1101_0000))
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0b0101_0000))
		try sut.execute(instruction: .makeShiftLeft(registerX: 0, registerY: 1))
		XCTAssertEqual(sut.registers[0], 0b1010_0000, "Register 0 should be equal to register 0 shifted right once")
		XCTAssertEqual(sut.registers[1], 0b0101_0000, "Register 1 should remain unaffected")
		XCTAssertEqual(sut.registers[0x0f], 1, "Register F should contain shifted out bit")
	}
}
