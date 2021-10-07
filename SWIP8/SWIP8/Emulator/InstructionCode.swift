//
//  Codes.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import Foundation

protocol InstructionCode {
}

enum InstructionGroup: UInt8, InstructionCode {
	case special = 0x00
	case jump = 0x01
	case call = 0x02
	case skipIf = 0x03
	case skipIfNot = 0x04
	case skipIfRegister = 0x05
	case setRegister = 0x06
	case addToRegister = 0x07
	case arithmetic = 0x08
	case skipIfNotRegister = 0x09
	case setIndex = 0x0a
	case jumpWithOffset = 0x0b
	case random = 0x0c
	case draw = 0x0d
	case skipIfKey = 0x0e
	case extended = 0x0f
}

enum KeyStateCode: UInt8, InstructionCode {
	case pressed = 0x9e
	case notPressed = 0xa1
}

enum ArithmeticCode: UInt8, InstructionCode {
	case copy = 0x00
	case or = 0x01
	case and = 0x02
	case xor = 0x03
	case add = 0x04
	case subtract = 0x05
	case shiftRight = 0x06
	case revSubtract = 0x07
	case shiftLeft = 0x0e
}

enum SpecialCode: UInt8, InstructionCode {
	case clearScreen = 0xe0
	case popStack = 0xee
}

enum ExtendedCode: UInt8, InstructionCode {
	case readDelayTimer = 0x07
	case waitForKey = 0x0a
	case setDelayTimer = 0x15
	case setSoundTimer = 0x018
	case addToIndex = 0x1e
	case indexToChar = 0x29
	case bcd = 0x33
	case storeRegisters = 0x55
	case loadRegisters = 0x65
}
