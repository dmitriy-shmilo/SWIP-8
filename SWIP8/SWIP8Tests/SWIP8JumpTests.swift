//
//  SWIP8JumpTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 05.10.2021.
//

import XCTest
@testable import SWIP8

class SWIP8JumpTests: XCTestCase {

	var sut = Emulator()

	override func setUpWithError() throws {
		sut.reset()
	}

	func testJump() throws {
		let address: UInt16 = sut.programCounter + 8

		try sut.execute(instruction: .makeJump(address: address))
		XCTAssertEqual(sut.programCounter, address, "PC should point to \(address) after jump")
		XCTAssertEqual(sut.stack.count, 0, "Expected call stack to remain empty after jump")
	}
	
	func testJumpOutOfBounds() throws {
		let address: UInt16 = 0xfff0

		XCTAssertThrowsError(
			try sut.execute(instruction: .makeJump(address: address)),
			"Expexted an error when jumping outside of addressable memory"
		)
	}
	
	func testJumpReserved() throws {
		let address: UInt16 = 0x000f

		XCTAssertThrowsError(
			try sut.execute(instruction: .makeJump(address: address)),
			"Expexted an error when jumping into reserved memory"
		)
	}
	
	func testJumpWithOffset() throws {
		let address: UInt16 = sut.programCounter + 8

		try sut.execute(instruction: .makeSetRegister(register: 0, value: 8))
		try sut.execute(instruction: .makeJumpWithOffset(address: address))
		XCTAssertEqual(sut.programCounter, address + 8, "PC should point to given address with V0 value as offset")
	}
	
	func testJumpWithOffsetOutOfBounds() throws {
		let address: UInt16 = 0x0fff

		try sut.execute(instruction: .makeSetRegister(register: 0, value: 8))
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeJumpWithOffset(address: address)),
			"Expected an error when jumping out of addressable memory"
		)
	}
	
	func testJumpWithOffsetReserved() throws {
		let address: UInt16 = 0x000f

		try sut.execute(instruction: .makeSetRegister(register: 0, value: 8))
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeJumpWithOffset(address: address)),
			"Expected an error when jumping into reserved memory"
		)
	}
	
	func testJumpWithOffsetAlt() throws {
		let address: UInt16 = 0x0200
		
		XCTFail("Expected an option to toggle jump with offset modes")
		try sut.execute(instruction: .makeSetRegister(register: 2, value: 8))
		try sut.execute(instruction: .makeJumpWithOffset(address: address))
		XCTAssertEqual(sut.programCounter, address + 8, "PC should point to given address with VX value as offset")
	}
	
	func testJumpWithOffsetAltOutOfBounds() throws {
		let address: UInt16 = 0x0eff

		XCTFail("Expected an option to toggle jump with offset modes")
		try sut.execute(instruction: .makeSetRegister(register: 0x0e, value: 0xff))
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeJumpWithOffset(address: address)),
			"Expected an error when jumping out of addressable memory"
		)
	}
	
	func testJumpWithOffsetAltReserved() throws {
		let address: UInt16 = 0x010f

		XCTFail("Expected an option to toggle jump with offset modes")
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 8))
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeJumpWithOffset(address: address)),
			"Expected an error when jumping into reserved memory"
		)
	}

}
