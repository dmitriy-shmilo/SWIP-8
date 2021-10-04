//
//  Instruction.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import Foundation

enum InstructionGroup: UInt8, ExpressibleByIntegerLiteral {
	typealias IntegerLiteralType = UInt8
	
	init(integerLiteral value: UInt8) {
		self.init(rawValue: value)!
	}
	
	case Special = 0x00
	case Jump = 0x01
	case Call = 0x02
	case SkipIf = 0x03
	case SkipIfNot = 0x04
	case SkipIfRegister = 0x05
	case SetRegister = 0x06
	case AddToRegister = 0x07
	case Arithmetic = 0x08
	case SkipIfNotRegister = 0x09
	case SetIndex = 0x0a
	case JumpMod = 0x0b
	case Random = 0x0c
	case Draw = 0x0d
	case SkipIfKey = 0x0e
	case Extended = 0x0f
}

struct Instruction: Equatable {
	let a: UInt8
	let b: UInt8
	
	init(a: UInt8, b: UInt8) {
		self.a = a
		self.b = b
	}
	
	init(group: InstructionGroup, x: UInt8, y: UInt8, n: UInt8) {
		self.a = group.rawValue << 4 | x
		self.b = y << 4 | n
	}
	
	init(group: InstructionGroup, combined: UInt16) {
		self.a = group.rawValue << 4 | UInt8((combined & 0x0fff) >> 8)
		self.b = UInt8(combined & 0x00ff)
	}
	
	init(group: InstructionGroup, x: UInt8, b: UInt8) {
		self.a = group.rawValue << 4 | x
		self.b = b
	}

	var group: InstructionGroup {
		// force unwrap is fine, since InstructionGroup spans over all possible 4-bit values
		.init(rawValue: a >> 4)!
	}
	
	var x: UInt8 {
		a & 0x0f
	}
	
	var y: UInt8 {
		b >> 4
	}
	
	var n: UInt8 {
		b & 0x0f
	}
	
	var nnn: UInt16 {
		UInt16(x) << 8 | UInt16(b)
	}
}

extension Instruction {
	static func makeClearScreen() -> Instruction {
		Instruction(group: .Special, x: 0, y: 0, n: 0x0e)
	}
	
	static func makeReturn() -> Instruction {
		Instruction(group: .Special, x: 0, y: 0, n: 0xee)
	}
	
	static func makeJump(address: UInt16) -> Instruction {
		Instruction(group: .Jump, combined: address)
	}
	
	static func makeCall(address: UInt16) -> Instruction {
		Instruction(group: .Call, combined: address)
	}
	
	static func makeSkipIf(register: UInt8, value: UInt8) -> Instruction {
		Instruction(group: .SkipIf, x: register, b: value)
	}
	
	static func makeSkipIfNot(register: UInt8, value: UInt8) -> Instruction {
		Instruction(group: .SkipIfNot, x: register, b: value)
	}
	
	static func makeSkipIfRegister(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .SkipIfRegister, x: registerX, y: registerY, n: 0)
	}
	
	static func makeSetRegister(register: UInt8, value: UInt8) -> Instruction {
		Instruction(group: .SetRegister, x: register, b: value)
	}
	
	static func makeAddToRegister(register: UInt8, value: UInt8) -> Instruction {
		Instruction(group: .AddToRegister, x: register, b: value)
	}
	
	// TODO: implement make arithmetic instructions
	
	static func makeSkipIfNotRegister(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .SkipIfNotRegister, x: registerX, y: registerY, n: 0)
	}
	
	static func makeSetIndex(address: UInt16) -> Instruction {
		Instruction(group: .SetIndex, combined: address)
	}
	
	static func makeJumpMod(address: UInt16) -> Instruction {
		Instruction(group: .JumpMod, combined: address)
	}
	
	static func makeRandom(register: UInt8, mod: UInt8) -> Instruction {
		Instruction(group: .Random, x: register, b: mod)
	}
	
	static func makeDraw(registerX: UInt8, registerY: UInt8, rows: UInt8) -> Instruction {
		Instruction(group: .Draw, x: registerX, y: registerY, n: rows)
	}
	
	static func makeSkipIfKeyPressed(registerX: UInt8) -> Instruction {
		// TODO: move magic numbers into constants
		Instruction(group: .SkipIfKey, x: registerX, b: 0x9e)
	}
	
	static func makeSkipIfKeyNotPressed(registerX: UInt8) -> Instruction {
		Instruction(group: .SkipIfKey, x: registerX, b: 0xa1)
	}
	
	static func makeReadDelayTimer(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x07)
	}
	
	static func makeWaitForKey(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x0a)
	}
	
	static func makeSetDelayTimer(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x15)
	}
	
	static func makeSetSoundTimer(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x18)
	}
	
	static func makeAddToIndex(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x1E)
	}
	
	static func makeIndexToChar(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x29)
	}
	
	static func makeBCD(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x33)
	}
	
	static func makeStoreRegisters(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x55)
	}
	
	static func makeReadRegisters(registerX: UInt8) -> Instruction {
		Instruction(group: .Extended, x: registerX, b: 0x65)
	}
}
