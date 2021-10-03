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
		XCTAssertEqual(sut.group, 0x01)
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
}
