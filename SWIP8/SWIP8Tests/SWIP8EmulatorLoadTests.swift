//
//  SWIP8EmulatorLoadTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import XCTest
@testable import SWIP8

class SWIP8EmulatorLoadTests: XCTestCase {

	let sut = Emulator()

    override func setUpWithError() throws {
		sut.reset()
    }

	func testLoad() throws {
		let rom: [UInt8] = [0x01, 0x02, 0x03, 0x04]
		let memorySize = sut.memory.count
		sut.load(rom: rom)
		XCTAssertEqual(sut.memory.count, memorySize, "Loading ROM shouldn't affect memory size")
		XCTAssertEqual(sut.peekInstruction(), Instruction(a: 0x01, b: 0x02), "Emulator should point to the first instruction")
	}
	
	func testLoadEmpty() throws {
		let rom: [UInt8] = []
		XCTAssertThrowsError(sut.load(rom: rom), "Loading an empty rom should be an error")
	}
	
	func testLoadOdd() throws {
		let rom: [UInt8] = [0x01, 0x02, 0x03]
		XCTAssertThrowsError(sut.load(rom: rom), "Loading a rom with odd number of bytes shoud be an error")
	}
	
	func testLoadExceedingMemory() throws {
		let availableMemory = sut.memory.count
		let rom = Array<UInt8>(repeating: 0x01, count: availableMemory)
		XCTAssertThrowsError(sut.load(rom: rom), "Loading a rom, which exceeds available memory, shoud be an error")
	}
	
	func testLoadExactlyFitting() throws {
		let availableMemory = sut.memory.count
		var rom = Array<UInt8>(repeating: 0x01, count: availableMemory - Int(Emulator.ReservedMemorySize))
		rom[rom.count - 1] = 0x02
		sut.load(rom: rom)
		XCTAssertEqual(sut.memory.last ?? 0, 0x02, "Last byte of loaded memory should be preserved")
	}
}
