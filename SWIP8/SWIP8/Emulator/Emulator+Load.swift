//
//  Emulator+Load.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 18.10.2021.
//

import Foundation

extension Emulator {
	func load(instructions: Instruction...) throws {
		var rom = [UInt8]()
		rom.reserveCapacity(instructions.count * 2)

		for i in instructions {
			rom.append(i.a)
			rom.append(i.b)
		}

		try load(rom: rom)
	}

	func load(string: String) throws {
		let totalSteps = 1
		var bytes = [UInt8]()
		var step = totalSteps
		var byte: UInt8 = 0

		for char in string {
			if CharacterSet.whitespacesAndNewlines.contains(char.unicodeScalars.first!) {
				continue
			}

			if let digit = char.hexDigitValue {
				byte |= UInt8(digit)
				if step == 0 {
					bytes.append(byte)
					byte = 0
					step = totalSteps
				} else {
					byte <<= 4
					step -= 1
				}
			} else {
				throw LoadError.InvalidCharacter(string: String(char))
			}
		}

		// there's an incomplete byte left lingering
		if step != totalSteps {
			throw LoadError.InvalidInputLength
		}

		try load(rom: bytes)
	}
}
