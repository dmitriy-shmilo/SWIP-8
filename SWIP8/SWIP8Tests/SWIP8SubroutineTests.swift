//
//  SWIP8SubroutineTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 05.10.2021.
//


import XCTest
@testable import SWIP8

class SWIP8SubroutineTests: XCTestCase {
	
	var sut = Emulator()
	
	override func setUpWithError() throws {
		sut.reset()
	}
	
	func testCall() throws {
		let routineAddress: UInt16 = 0x0ff0
		
		try sut.execute(instruction: .makeCall(address: routineAddress))
		XCTAssertEqual(sut.stack.count, 1, "Expected call stack to grow by one after call")
		XCTAssertEqual(sut.programCounter, routineAddress, "PC should point to routine address after call")
		try sut.execute(instruction: .makeCall(address: routineAddress))
		XCTAssertEqual(sut.stack.count, 2, "Expected call stack to grow by one after call")
		XCTAssertEqual(sut.programCounter, routineAddress, "PC should point to routine address after call")
	}
	
	func testReturn() throws {
		let routineAddress: UInt16 = 0x0ff0
		let originalAddress = sut.programCounter
		
		try sut.execute(instruction: .makeCall(address: routineAddress))
		try sut.execute(instruction: .makeCall(address: routineAddress))
		try sut.execute(instruction: .makeReturn())
		XCTAssertEqual(sut.stack.count, 1, "Expected call stack to decrement after return")
		XCTAssertEqual(sut.programCounter, routineAddress, "PC should point to previous address after return")
		try sut.execute(instruction: .makeReturn())
		XCTAssertEqual(sut.stack.count, 0, "Expected call stack to be empty after return")
		XCTAssertEqual(sut.programCounter, originalAddress, "PC should point to original address after return")
	}
	
	func testTerminate() throws {
		let routineAddress: UInt16 = 0x0ff0
		
		try sut.execute(instruction: .makeCall(address: routineAddress))
		try sut.execute(instruction: .makeReturn())
		try sut.execute(instruction: .makeReturn())
		XCTAssertEqual(sut.quit, true, "Expected emulator to stop after stack underflow")
	}
	
	func testCallInvalid() throws {
		let routineAddress: UInt16 = 0x00f0
		
		XCTAssertThrowsError(
			try sut.execute(instruction: .makeCall(address: routineAddress)),
			"Expected an error when calling into reserved memory"
		)
	}
	
	func testStackOverflow() throws {
		let routineAddress: UInt16 = 0x00f0
		
		
		XCTAssertThrowsError(
			{
				for _ in 0...100 {
					try self.sut.execute(instruction: .makeCall(address: routineAddress))
				}
			},
			"Expected an error when stack overflows"
		)
	}
}
