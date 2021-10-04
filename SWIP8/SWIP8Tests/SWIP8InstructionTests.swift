//
//  SWIP8Tests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import XCTest
@testable import SWIP8

class SWIP8InstructionTests: XCTestCase {

	private let sut = Instruction(a: 0x12, b: 0x34)

    func testFirstNibble() {
		XCTAssertEqual(sut.group, InstructionGroup.jump)
    }
	
	func testSecondNibble() {
		XCTAssertEqual(sut.x, 0x02)
	}
	
	func testThirdNibble() {
		XCTAssertEqual(sut.y, 0x03)
	}
	
	func testFourthNibble() {
		XCTAssertEqual(sut.n, 0x04)
	}
	
	func testCombinedNibbles() {
		XCTAssertEqual(sut.nnn, 0x0234)
	}
	
	func testSpecialCode() {
		let sut = Instruction.makeReturn()
		XCTAssertEqual(sut.specialCode, .popStack)
	}
	
	func testUnknownSpecialCode() {
		let sut = Instruction(a: 0x00, b: 0x00)
		XCTAssertEqual(sut.specialCode, nil)
	}
	
	func testArithmeticCode() {
		let sut = Instruction.makeAdd(registerX: 0, registerY: 1)
		XCTAssertEqual(sut.arithmeticCode, .add)
	}
	
	func testUnknownArithmeticCode() {
		let sut = Instruction(a: 0x00, b: 0x0f)
		XCTAssertEqual(sut.arithmeticCode, nil)
	}
	
	func testExtendedCode() {
		let sut = Instruction.makeBCD(registerX: 0)
		XCTAssertEqual(sut.extendedCode, .bcd)
	}
	
	func testUnknownExtendedCode() {
		let sut = Instruction(a: 0x00, b: 0xff)
		XCTAssertEqual(sut.extendedCode, nil)
	}
}
