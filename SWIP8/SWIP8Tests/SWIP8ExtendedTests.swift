//
//  SWIP8EmulatorTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import XCTest
@testable import SWIP8

class SWIP8ExtendedTests: XCTestCase {
	
	var sut = Emulator()
	
	override func setUpWithError() throws {
		sut.reset()
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
	
	func testBCDOutOfBounds() throws {
		let value: UInt8 = 123
		let address: UInt16 = 0x0fff
		
		try sut.execute(instruction: .makeSetIndex(address: address))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeBCD(registerX: 0)),
			"Expexted an invalid index error"
		)
	}
	
	func testBCDReserved() throws {
		let value: UInt8 = 123
		let address: UInt16 = 0x000f
		
		try sut.execute(instruction: .makeSetIndex(address: address))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: value))
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeBCD(registerX: 0)),
			"Expexted an invalid index error"
		)
	}
	
	func testStoreRegisters() throws {
		let indexAddress: UInt16 = 0x0200
		try sut.execute(instruction: .makeSetIndex(address: indexAddress))
		for i in 0..<sut.registers.count {
			try sut.execute(instruction: .makeAddToRegister(register: UInt8(i), value: UInt8(i) + 1))
		}
		try sut.execute(instruction: .makeStoreRegisters(registerX: 0x0f))
		
		for i in 0..<UInt16(sut.registers.count) {
			XCTAssertEqual(sut.memory[indexAddress + i], UInt8(i) + 1, "Index + \(i) should equal to \(i + 1)")
		}
		XCTAssertEqual(sut.indexRegister, indexAddress, "Expected index to remain unchanged")
	}
	
	func testStoreRegistersIncrementsIndex() throws {
		let indexAddress: UInt16 = 0x0200
		
		XCTFail("Expected an option to toggle store registers mode")
		try sut.execute(instruction: .makeSetIndex(address: indexAddress))
		for i in 0..<sut.registers.count {
			try sut.execute(instruction: .makeAddToRegister(register: UInt8(i), value: UInt8(i) + 1))
		}
		try sut.execute(instruction: .makeStoreRegisters(registerX: 0x0f))
		
		for i in 0..<UInt16(sut.registers.count) {
			XCTAssertEqual(sut.memory[indexAddress + i], UInt8(i) + 1, "Index + \(i) should equal to \(i + 1)")
		}
		XCTAssertEqual(sut.indexRegister, indexAddress + UInt16(sut.registers.count), "Expected index to increment by X")
	}
	
	func testStoreRegistersOutOfBounds() throws {
		let indexAddress: UInt16 = 0x0ffe
		try sut.execute(instruction: .makeSetIndex(address: indexAddress))
		
		for i in 0..<sut.registers.count {
			try sut.execute(instruction: .makeAddToRegister(register: UInt8(i), value: UInt8(i) + 1))
		}
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeStoreRegisters(registerX: 0x0f)),
			"Expexted an invalid index error"
		)
	}
	
	func testStoreRegistersReserved() throws {
		let indexAddress: UInt16 = 0x0200 - 4
		try sut.execute(instruction: .makeSetIndex(address: indexAddress))
		
		for i in 0..<sut.registers.count {
			try sut.execute(instruction: .makeAddToRegister(register: UInt8(i), value: UInt8(i) + 1))
		}
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeStoreRegisters(registerX: 0x0f)),
			"Expexted an invalid index error"
		)
	}
	
	func testLoadRegisters() throws {
		let indexAddress = sut.indexRegister
		let rom = stride(
			from: UInt8(1),
			to: UInt8(sut.registers.count + 1),
			by: 1
		).map { $0 }
		try sut.load(rom: rom)
		
		try sut.execute(instruction: .makeLoadRegisters(registerX: UInt8(sut.registers.count - 1)))
		
		for i in 0..<UInt16(sut.registers.count) {
			XCTAssertEqual(sut.registers[i],
							rom[i], "Register \(i) should equal to \(rom[i])")
		}
		XCTAssertEqual(sut.indexRegister, indexAddress, "Expected index to remain unchanged")
	}
	
	func testLoadRegistersIncrementsIndex() throws {
		XCTFail("Expected an option to toggle store registers mode")
		let indexAddress = sut.indexRegister
		let rom = stride(
			from: UInt8(1),
			to: UInt8(sut.registers.count + 1),
			by: 1
		).map { $0 }
		try sut.load(rom: rom)
		
		try sut.execute(instruction: .makeLoadRegisters(registerX: UInt8(sut.registers.count - 1)))
		
		for i in 0..<UInt16(sut.registers.count) {
			XCTAssertEqual(sut.registers[i],
							rom[i], "Register \(i) should equal to \(rom[i])")
		}
		XCTAssertEqual(sut.indexRegister, indexAddress + UInt16(sut.registers.count), "Expected index to increment by X")
	}
	
	func testLoadRegistersOutOfBounds() throws {
		let indexAddress: UInt16 = 0x0ffe
		let rom = stride(
			from: UInt8(1),
			to: UInt8(sut.registers.count + 1),
			by: 1
		).map { $0 }
		try sut.load(rom: rom)
		
		try sut.execute(instruction: .makeSetIndex(address: indexAddress))
		
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeLoadRegisters(registerX: UInt8(sut.registers.count - 1))),
			"Expexted invalid index error"
		)
	}
	
	func testLoadRegistersReserved() throws {
		let indexAddress: UInt16 = 0x000f
		let rom = stride(
			from: UInt8(1),
			to: UInt8(sut.registers.count + 1),
			by: 1
		).map { $0 }
		try sut.load(rom: rom)
		
		try sut.execute(instruction: .makeSetIndex(address: indexAddress))
		
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeLoadRegisters(registerX: UInt8(sut.registers.count - 1))),
			"Expexted invalid index error"
		)
	}
}
