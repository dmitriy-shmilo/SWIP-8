//
//  EmulatorRegisterTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 05.10.2021.
//

import XCTest
@testable import SWIP8

class EmulatorRegisterTests: XCTestCase {
	
	let sut = Emulator()
	
	override func setUpWithError() throws {
		sut.reset()
	}
	
	func testSetRegister() throws {
		for i in 0..<sut.registers.count {
			try sut.execute(instruction: .makeSetRegister(register: UInt8(i), value: UInt8(i) + 1))
		}
		
		for i in 0..<sut.registers.count {
			XCTAssertEqual(sut.registers[i], UInt8(i + 1), "Register #\(i) should contain \(i + 1)")
		}
	}
	
	func testAddToRegister() throws {
		for i in 0..<sut.registers.count {
			try sut.execute(instruction: .makeAddToRegister(register: UInt8(i), value: UInt8(i) + 1))
		}
		
		for i in 0..<sut.registers.count {
			XCTAssertEqual(sut.registers[i], UInt8(i + 1), "Register #\(i) should contain \(i + 1)")
		}
	}
	
	func testAddToRegisterOverflow() throws {
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 250))
		try sut.execute(instruction: .makeAddToRegister(register: 1, value: 100))
		
		XCTAssertEqual(sut.registers[1], 250 &+ 100, "Register 1 should contain wrapped sum")
		XCTAssertEqual(sut.registers[0xf], 0, "Register F should remain zero")
	}
}
