//
//  EmulatorDrawTests.swift
//  SWIP8Tests
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import XCTest
@testable import SWIP8

class EmulatorDrawTests: XCTestCase {

	let sut = Emulator()

	override func setUpWithError() throws {
		sut.reset()
	}

	func testDrawPixel() throws {
		try sut.load(rom: [0b1000_0000, 0x00])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0)) // x = 0
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0)) // y = 0
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 1))

		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if (x, y) == (0, 0) {
					XCTAssertNotEqual(pixel, 0, "Pixel at (0,0) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testDrawPixelOnRightEdge() throws {
		try sut.load(rom: [0b1000_0000, 0x00])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: UInt8(Emulator.ResolutionWidth - 1))) // x = 63
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 3)) // y = 3
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 1))

		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if (x, y) == (Emulator.ResolutionWidth - 1, 3) {
					XCTAssertNotEqual(pixel, 0, "Pixel at (0,0) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testDrawNoRows() throws {
		try sut.load(rom: [0b1000_0000, 0x00])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0)) // x = 0
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0)) // y = 0
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 0))

		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
			}
		}
	}

	func testDrawPixelWraps() throws {
		try sut.load(rom: [0b1000_0000, 0x00])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: UInt8(Emulator.ResolutionWidth + 1))) // x = 1
		try sut.execute(instruction: .makeSetRegister(register: 1, value: UInt8(Emulator.ResolutionHeight + 3))) // y = 3
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 1))

		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if (x, y) == (1, 3) {
					XCTAssertNotEqual(pixel, 0, "Pixel at (0,0) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testDrawHLine() throws {
		try sut.load(rom: [0xff, 0x00])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 1)) // x = 1
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 2)) // y = 2
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 1))

		// screen should be empty with an 8px horizontal line starting at (1, 2)
		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if 1...8 ~= x && y == 2 {
					XCTAssertNotEqual(pixel, 0, "Pixel at (\(x),\(y)) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testDrawClippedHLine() throws {
		try sut.load(rom: [0xff, 0x00])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: UInt8(Emulator.ResolutionWidth) - 5)) // x = 59
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 2)) // y = 2
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 1))

		// screen should be empty with a 4px horizontal line starting at (-4, 2)
		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if (Emulator.ResolutionWidth - 5)..<Emulator.ResolutionWidth ~= x && y == 2 {
					XCTAssertNotEqual(pixel, 0, "Pixel at (\(x),\(y)) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testDrawRect() throws {
		try sut.load(rom: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 1)) // x = 1
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 2)) // y = 2
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 8))

		// screen should be empty with an 8x8px rectangle line starting at (1, 2)
		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if 1...8 ~= x && 2...9 ~= y {
					XCTAssertNotEqual(pixel, 0, "Pixel at (\(x),\(y)) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testDrawClippedRect() throws {
		try sut.load(rom: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: UInt8(Emulator.ResolutionWidth) - 6)) // x = 57
		try sut.execute(instruction: .makeSetRegister(register: 1, value: UInt8(Emulator.ResolutionHeight) - 5)) // y = 27
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 8))

		// screen should be empty with a 4x4px rectangle line starting at (-6, -4)
		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if (Emulator.ResolutionWidth - 6)..<Emulator.ResolutionWidth ~= x
					&& (Emulator.ResolutionHeight - 5)..<Emulator.ResolutionHeight ~= y {
					XCTAssertNotEqual(pixel, 0, "Pixel at (\(x),\(y)) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testDrawGrid() throws {
		try sut.load(rom: [0b0101_0101, 0b1010_1010])

		for i: UInt8 in 0..<4 {
			try sut.execute(instruction: .makeSetRegister(register: 0, value: 0)) // x = 0
			try sut.execute(instruction: .makeSetRegister(register: 1, value: i * 2)) // y = 0, 2, 4, 6
			try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 2))
		}

		// screen should be empty with an 8x8px alternating grid starting at (0,0)
		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if [0, 2, 4, 6].contains(x) && [1, 3, 5, 7].contains(y) {
					XCTAssertNotEqual(pixel, 0, "Pixel at (\(x),\(y)) should be set")
				} else if [1, 3, 5, 7].contains(x) && [0, 2, 4, 6].contains(y) {
					XCTAssertNotEqual(pixel, 0, "Pixel at (\(x),\(y)) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testEraseRect() throws {
		try sut.load(rom: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 1)) // x = 1
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 2)) // y = 2
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 8))
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 8))

		// screen should be empty
		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
			}
		}
	}

	func testPartialEraseRect() throws {
		try sut.load(rom: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 1)) // x = 1
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 2)) // y = 2
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 8))

		try sut.execute(instruction: .makeSetRegister(register: 0, value: 2)) // x = 2
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 3)) // y = 3
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 8))

		// screen should be empty with vertical lines originating from (1, 2) and (8, 3)
		// and horizontal ones originating from (1, 2) and (2, 9)
		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				if 1...8 ~= x && y == 2
					|| x == 1 && 2...9 ~= y
					|| x == 9 && 3...10 ~= y
					|| 2...9 ~= x && y == 10 {
					XCTAssertNotEqual(pixel, 0, "Pixel at (\(x),\(y)) should be set")
				} else {
					XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
				}
			}
		}
	}

	func testClearScreen() throws {
		try sut.load(rom: [0b1000_0000, 0x00])
		try sut.execute(instruction: .makeSetRegister(register: 0, value: 0)) // x = 0
		try sut.execute(instruction: .makeSetRegister(register: 1, value: 0)) // y = 0
		try sut.execute(instruction: .makeDraw(registerX: 0, registerY: 1, rows: 1)) // draw one pixel
		try sut.execute(instruction: .makeClearScreen())

		// the whole screen should be empty
		for x in 0..<Emulator.ResolutionWidth {
			for y in 0..<Emulator.ResolutionHeight {
				let pixel = sut.getPixel(x: x, y: y)
				XCTAssertEqual(pixel, 0, "Pixel at (\(x),\(y)) should not be set")
			}
		}
	}
}
