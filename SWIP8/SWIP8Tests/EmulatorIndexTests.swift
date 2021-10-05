//
//  EmulatorIndexTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 05.10.2021.
//

import Foundation

import XCTest
@testable import SWIP8

class EmulatorIndexTests: XCTestCase {
	
	let sut = Emulator()
	
	override func setUpWithError() throws {
		sut.reset()
	}

	func testSetIndex() throws {
		let address: UInt16 = 0x0ff0
		try sut.execute(instruction: .makeSetIndex(address: address))
		XCTAssertEqual(sut.indexRegister, address, "Index register should point to a given address")
	}
	
	func testSetIndexOutOfBounds() throws {
		let address: UInt16 = 0xfff0
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeSetIndex(address: address)),
			"Expected an invalid index error"
		)
	}
	
	func testSetIndexReserved() throws {
		let address: UInt16 = 0x000f
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeSetIndex(address: address)),
			"Expected an invalid index error"
		)
	}
	
	func testAddToIndex() throws {
		let address: UInt16 = 0x0200
		try sut.execute(instruction: .makeSetIndex(address: address))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 8))
		try sut.execute(instruction: .makeAddToIndex(registerX: 0))
		XCTAssertEqual(sut.indexRegister, address + 8, "Index register should point to an adjusted address")
	}
	
	func testAddToIndexOutOfBounds() throws {
		let address: UInt16 = 0xfff0
		try sut.execute(instruction: .makeSetIndex(address: address))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 8))
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeAddToIndex(registerX: 0)),
			"Expected an invalid index error"
		)
	}
	
	func testAddToIndexReserved() throws {
		let address: UInt16 = 0x000f
		try sut.execute(instruction: .makeSetIndex(address: address))
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 8))
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeAddToIndex(registerX: 0)),
			"Expected an invalid index error"
		)
	}
	
	func testIndexToChar() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 3))
		try sut.execute(instruction: .makeIndexToChar(registerX: 0))
		
		let dIndex = sut.indexRegister
		
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 4))
		try sut.execute(instruction: .makeIndexToChar(registerX: 0))
		
		let eIndex = sut.indexRegister
		
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 3))
		try sut.execute(instruction: .makeIndexToChar(registerX: 0))
		
		XCTAssertNotEqual(dIndex, eIndex, "Indices for E and D chars should be different")
		XCTAssertEqual(dIndex, sut.indexRegister, "Indices for the same character should be same")
	}
	
	func testIndexResets() throws {
		let zeroIndex = sut.indexRegister
		try sut.execute(instruction: .makeSetIndex(address: zeroIndex + 8))
		sut.reset()
		
		XCTAssertEqual(zeroIndex, sut.indexRegister, "Index register should reset to the same value")
	}
}
