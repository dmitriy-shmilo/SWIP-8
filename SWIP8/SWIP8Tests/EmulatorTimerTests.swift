//
//  EmulatorTimerTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 05.10.2021.
//

import XCTest
@testable import SWIP8

class EmulatorTimerTests: XCTestCase {
	
	let sut = Emulator()
	
	override func setUpWithError() throws {
		sut.reset()
	}
	
	func testSetDelayTimer() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 100))
		try sut.execute(instruction: .makeSetDelayTimer(registerX: 0))
		XCTAssertEqual(sut.delayTimer, 100, "Delay timer should be set to 100")
	}
	
	func testSetSoundTimer() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 100))
		try sut.execute(instruction: .makeSetSoundTimer(registerX: 0))
		XCTAssertEqual(sut.soundTimer, 100, "Sound timer should be set to 100")
	}
	
	func testReadDelayTimer() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 100))
		try sut.execute(instruction: .makeSetDelayTimer(registerX: 0))
		sut.tickTimers()
		try sut.execute(instruction: .makeReadDelayTimer(registerX: 1))
		
		XCTAssertEqual(sut.registers[1], 99, "Reading timer should out updated timer value into VX")
	}
	
	func testDelayTimerTicksDown() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 100))
		try sut.execute(instruction: .makeSetDelayTimer(registerX: 0))
		sut.tickTimers()
		XCTAssertEqual(sut.delayTimer, 99, "Ticking delay timer should decrement.")
	}
	
	func testDelayTimerStaysZero() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2))
		try sut.execute(instruction: .makeSetDelayTimer(registerX: 0))
		sut.tickTimers() // 1
		sut.tickTimers() // 0
		sut.tickTimers() // 0
		XCTAssertEqual(sut.delayTimer, 0, "Ticking delay timer should stop at zero.")
	}
	
	func testDelayTimerResets() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2))
		try sut.execute(instruction: .makeSetDelayTimer(registerX: 0))
		sut.reset()
		XCTAssertEqual(sut.delayTimer, 0, "Resetting emulator should set delay timer to zero.")
	}
	
	func testSoundTimerTicksDown() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 100))
		try sut.execute(instruction: .makeSetDelayTimer(registerX: 0))
		sut.tickTimers()
		XCTAssertEqual(sut.delayTimer, 99, "Ticking sound timer should decrement.")
	}
	
	func testSoundTimerStaysZero() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2))
		try sut.execute(instruction: .makeSetSoundTimer(registerX: 0))
		sut.tickTimers() // 1
		sut.tickTimers() // 0
		sut.tickTimers() // 0
		XCTAssertEqual(sut.soundTimer, 0, "Ticking sound timer should stop at zero.")
	}
	
	func testSoundTimerResets() throws {
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2))
		try sut.execute(instruction: .makeSetSoundTimer(registerX: 0))
		sut.reset()
		XCTAssertEqual(sut.delayTimer, 0, "Resetting emulator should set sound timer to zero.")
	}
}
