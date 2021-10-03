//
//  Instruction.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import Foundation

extension Array {
	subscript(word: UInt16) -> Element {
		self[Int(word)]
	}
	
	subscript(range: Range<UInt16>) -> SubSequence {
		self[Int(range.startIndex)..<Int(range.endIndex)]
	}
}

class Emulator {
	private static let FontData: [UInt8] = [
		0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
		0x20, 0x60, 0x20, 0x20, 0x70, // 1
		0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
		0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
		0x90, 0x90, 0xF0, 0x10, 0x10, // 4
		0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
		0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
		0xF0, 0x10, 0x20, 0x40, 0x40, // 7
		0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
		0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
		0xF0, 0x90, 0xF0, 0x90, 0x90, // A
		0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
		0xF0, 0x80, 0x80, 0x80, 0xF0, // C
		0xE0, 0x90, 0x90, 0x90, 0xE0, // D
		0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
		0xF0, 0x80, 0xF0, 0x80, 0x80  // F
	]
	private static let FontDataOffset = 0x00

	var memory = Array<UInt8>(repeating: 0, count: 4096)
	var display = Array<UInt8>(repeating: 0, count: 64 * 32)
	var registers = Array<UInt8>(repeating: 0, count: 16)
	var programCounter: UInt16 = 512
	var indexRegister: UInt16 = 0
	var stack = Array<UInt16>()
	var delayTimer: UInt8 = 0
	var soundTimer: UInt8 = 0
	var quit = false
	
	init() {
		for i in 0..<Self.FontData.count {
			memory[i + Self.FontDataOffset] = Self.FontData[i]
		}
	}
}
