//
//  Instruction.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import Foundation

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
	var specialCode: SpecialCode? {
		.init(rawValue: b)
	}
	
	var arithmeticCode: ArithmeticCode? {
		.init(rawValue: n)
	}
	
	var extendedCode: ExtendedCode? {
		.init(rawValue: b)
	}
}

extension Instruction {
	// MARK: - Make Special instructions
	static func makeClearScreen() -> Instruction {
		Instruction(group: .special, x: 0, y: 0, n: SpecialCode.clearScreen.rawValue)
	}
	
	// MARK: - Make Jump instructions
	static func makeJump(address: UInt16) -> Instruction {
		Instruction(group: .jump, combined: address)
	}
	
	static func makeJumpMod(address: UInt16) -> Instruction {
		Instruction(group: .jumpMod, combined: address)
	}
	
	// MARK: - Make subroutine instructions
	static func makeCall(address: UInt16) -> Instruction {
		Instruction(group: .call, combined: address)
	}
	
	static func makeReturn() -> Instruction {
		Instruction(group: .special, x: 0, y: 0, n: SpecialCode.popStack.rawValue)
	}
	
	// MARK: - Make Skip instructions
	static func makeSkipIf(register: UInt8, value: UInt8) -> Instruction {
		Instruction(group: .skipIf, x: register, b: value)
	}
	
	static func makeSkipIfNot(register: UInt8, value: UInt8) -> Instruction {
		Instruction(group: .skipIfNot, x: register, b: value)
	}
	
	static func makeSkipIfRegister(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .skipIfRegister, x: registerX, y: registerY, n: 0)
	}
	
	static func makeSkipIfNotRegister(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .skipIfNotRegister, x: registerX, y: registerY, n: 0)
	}
	
	static func makeSkipIfKeyPressed(registerX: UInt8) -> Instruction {
		Instruction(group: .skipIfKey, x: registerX, b: SkipIfKeyState.pressed.rawValue)
	}
	
	static func makeSkipIfKeyNotPressed(registerX: UInt8) -> Instruction {
		Instruction(group: .skipIfKey, x: registerX, b: SkipIfKeyState.notPressed.rawValue)
	}
	
	// MARK: - Make register modification instructions
	static func makeSetRegister(register: UInt8, value: UInt8) -> Instruction {
		Instruction(group: .setRegister, x: register, b: value)
	}
	
	static func makeAddToRegister(register: UInt8, value: UInt8) -> Instruction {
		Instruction(group: .addToRegister, x: register, b: value)
	}
	
	// MARK: - Make arithmetic and boolean instructions
	static func makeCopyRegister(registerX: UInt8, from registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.copy.rawValue)
	}
	
	static func makeOr(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.or.rawValue)
	}
	
	static func makeAnd(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.and.rawValue)
	}
	
	static func makeXor(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.xor.rawValue)
	}
	
	static func makeAdd(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.add.rawValue)
	}
	
	static func makeSubtract(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.subtract.rawValue)
	}
	
	static func makeShiftRight(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.shiftRight.rawValue)
	}
	
	static func makeReverseSubtract(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.revSubtract.rawValue)
	}
	
	static func makeShiftLeft(registerX: UInt8, registerY: UInt8) -> Instruction {
		Instruction(group: .arithmetic, x: registerX, y: registerY, n: ArithmeticCode.shiftLeft.rawValue)
	}
	
	// MARK: - Make index manipulation
	static func makeSetIndex(address: UInt16) -> Instruction {
		Instruction(group: .setIndex, combined: address)
	}
	
	static func makeAddToIndex(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.addToIndex.rawValue)
	}
	
	static func makeIndexToChar(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.indexToChar.rawValue)
	}
	
	// MARK: - Make random generator instructions
	static func makeRandom(register: UInt8, mod: UInt8) -> Instruction {
		Instruction(group: .random, x: register, b: mod)
	}
	
	// MARK: - Make draw instructions
	static func makeDraw(registerX: UInt8, registerY: UInt8, rows: UInt8) -> Instruction {
		Instruction(group: .draw, x: registerX, y: registerY, n: rows)
	}
	
	// MARK: - Make timer instructions
	static func makeReadDelayTimer(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.readDelayTimer.rawValue)
	}
	
	static func makeSetDelayTimer(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.setDelayTimer.rawValue)
	}
	
	static func makeSetSoundTimer(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.setSoundTimer.rawValue)
	}
	
	// MARK: - Make extended instructions
	static func makeWaitForKey(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.waitForKey.rawValue)
	}
	
	static func makeBCD(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.bcd.rawValue)
	}
	
	static func makeStoreRegisters(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.storeRegisters.rawValue)
	}
	
	static func makeReadRegisters(registerX: UInt8) -> Instruction {
		Instruction(group: .extended, x: registerX, b: ExtendedCode.readRegisters.rawValue)
	}
}
