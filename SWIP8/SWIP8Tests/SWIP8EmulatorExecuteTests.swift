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

		sut.execute(instruction: .makeJump(address: address))
		XCTAssertEqual(sut.programCounter, address, "PC should point to address after jump")
		XCTAssertEqual(sut.stack.count, 0, "Expected call stack to remain empty after jump")
	}
	
    func testCallReturn() throws {
		let routineAddress: UInt16 = 0x0ff0
		let originalAddress = sut.programCounter

		sut.execute(instruction: .makeCall(address: routineAddress))
		XCTAssertEqual(sut.stack.count, 1, "Expected call stack to grow by one after call")
		XCTAssertEqual(sut.programCounter, routineAddress, "PC should point to routine address after call")
		sut.execute(instruction: .makeReturn())
		XCTAssertEqual(sut.stack.count, 0, "Expected call stack to be empty after return")
		XCTAssertEqual(sut.programCounter, originalAddress, "PC should point to original address after return")
    }
	
	func testSetIndex() throws {
		let address: UInt16 = 0x0ff0
		sut.execute(instruction: .makeSetIndex(address: address))
		XCTAssertEqual(sut.indexRegister, address, "Index register should point to a given address")
	}
	
	func testSetRegister() throws {
		for i in 0..<sut.registers.count {
			sut.execute(instruction: .makeSetRegister(register: UInt8(i), value: UInt8(i) + 1))
		}
		
		for i in 0..<sut.registers.count {
			XCTAssertEqual(sut.registers[i], UInt8(i + 1), "Register #\(i) should contain \(i + 1)")
		}
	}
	
	func testBCD() throws {
		let value: UInt8 = 123
		let address: UInt16 = 0x0200

		sut.execute(instruction: .makeSetIndex(address: address))
		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeBCD(registerX: 0))
		
		XCTAssertEqual(sut.memory[address], 1)
		XCTAssertEqual(sut.memory[address + 1], 2)
		XCTAssertEqual(sut.memory[address + 2], 3)
	}
	
	func testSkipIfSkips() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeSkipIf(register: 0, value: value))
		
		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced by one instruction")
	}
	
	func testSkipIfDoesntSkip() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeSkipIf(register: 0, value: value + 1))
		
		XCTAssertEqual(sut.programCounter, pc, "PC should've been unaffected by a skip instruction")
	}
	
	func testSkipIfNotSkips() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeSkipIfNot(register: 0, value: value + 1))
		
		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced by one instruction")
	}
	
	func testSkipIfNotDoesntSkip() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeSkipIfNot(register: 0, value: value))
		
		XCTAssertEqual(sut.programCounter, pc, "PC should've been unaffected by a skip instruction")
	}
	
	func testSkipIfRegisterSkips() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeSetRegister(register: 1, value: value))
		sut.execute(instruction: .makeSkipIfRegister(registerX: 0, registerY: 1))
		
		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced by one instruction")
	}
	
	func testSkipIfRegisterDoesntSkip() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeSetRegister(register: 1, value: value + 1))
		sut.execute(instruction: .makeSkipIfRegister(registerX: 0, registerY: 1))
		
		XCTAssertEqual(sut.programCounter, pc, "PC should've been unaffected by a skip instruction")
	}
	
	func testSkipIfNotRegisterSkips() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeSetRegister(register: 1, value: value + 1))
		sut.execute(instruction: .makeSkipIfNotRegister(registerX: 0, registerY: 1))
		
		XCTAssertEqual(sut.programCounter, pc + 2, "PC should've been advanced by one instruction")
	}
	
	func testSkipIfNotRegisterDoesntSkip() throws {
		let value: UInt8 = 123
		let pc = sut.programCounter

		sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		sut.execute(instruction: .makeSetRegister(register: 1, value: value))
		sut.execute(instruction: .makeSkipIfNotRegister(registerX: 0, registerY: 1))
		
		XCTAssertEqual(sut.programCounter, pc, "PC should've been unaffected by a skip instruction")
	}

}
