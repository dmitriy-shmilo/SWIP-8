//
//  Instruction.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import Foundation

class Emulator {
	static let ReservedMemorySize: UInt16 = 512
	static let MemorySize: UInt16 = 4096
	static let RegisterCount = 16
	static let ResolutionHeight: UInt16 = 32
	static let ResolutionWidth: UInt16 = 64
	
	private static let FontDataOffset: UInt16 = 0x00
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
	
	private (set) var memory = Array<UInt8>(repeating: 0, count: Int(MemorySize))
	private (set) var display = Array<UInt8>(repeating: 0, count: Int(ResolutionWidth * ResolutionHeight))
	private (set) var registers = Array<UInt8>(repeating: 0, count: RegisterCount)
	private (set) var programCounter: UInt16 = ReservedMemorySize
	private (set) var indexRegister: UInt16 = ReservedMemorySize
	private (set) var stack = Array<UInt16>()
	private (set) var delayTimer: UInt8 = 0
	private (set) var soundTimer: UInt8 = 0
	private (set) var quit = false
	
	init() {
		
	}
	
	func reset() {
		quit = true
		indexRegister = Self.ReservedMemorySize
		programCounter = Self.ReservedMemorySize
		
		clearDisplay()
		registers.withUnsafeMutableBytes { ptr in
			_ = memset(ptr.baseAddress, 0, ptr.count)
		}
		memory.withUnsafeMutableBytes { ptr in
			_ = memset(ptr.baseAddress, 0, ptr.count)
		}
		memory.replaceSubrange(
			Int(Self.FontDataOffset)..<Int(Self.FontDataOffset) + Self.FontData.count,
			with: Self.FontData
		)
		stack.removeAll(keepingCapacity: true)
		
		delayTimer = 0
		soundTimer = 0
	}
	
	func load(rom: [UInt8]) throws {
		// each instruction is two bytes in length
		// TODO: There might be an odd number of data bytes, need to verify with the spec
		guard rom.count.isMultiple(of: 2) && rom.count > 0 else {
			throw LoadError.InvalidInputLength
		}
		
		guard rom.count <= Self.MemorySize - Self.ReservedMemorySize else {
			throw LoadError.NotEnoughMemory
		}
		
		reset()
		memory.replaceSubrange(
			Int(Self.ReservedMemorySize)..<Int(Self.ReservedMemorySize) + rom.count,
			with: rom
		)
		for i in 0..<UInt16(rom.count) {
			memory[Self.ReservedMemorySize + i] = rom[i]
		}
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
	
	func execute(instruction: Instruction) throws {
		switch instruction.group {
		case .Special:
			try executeSpecial(instruction: instruction)
		case .Jump:
			try executeJump(instruction: instruction)
		case .Call:
			try executeCall(instruction: instruction)
		case .SkipIf:
			try executeSkipIf(instruction: instruction)
		case .SkipIfNot:
			try executeSkipIfNot(instruction: instruction)
		case .SkipIfRegister:
			try executeSkipIfRegister(instruction: instruction)
		case .SetRegister:
			executeSetRegister(instruction: instruction)
		case .AddToRegister:
			executeAddToRegister(instruction: instruction)
		case .Arithmetic:
			try executeArithmetic(instruction: instruction)
		case .SkipIfNotRegister:
			try executeSkipIfNotRegister(instruction: instruction)
		case .SetIndex:
			executeSetIndex(instruction: instruction)
		case .JumpMod:
			try executeJumpMod(instruction: instruction)
		case .Random:
			executeRandom(instruction: instruction)
		case .Draw:
			executeDraw(instruction: instruction)
		case .SkipIfKey:
			try executeSkipIfKey(instruction: instruction)
		case .Extended:
			try executeExtended(instruction: instruction)
		}
	}
	
	func peekInstruction() -> Instruction {
		Instruction(a: memory[programCounter], b: memory[programCounter + 1])
	}
	
	func executeNextInstruction() throws {
		let instruction = peekInstruction()
		try advanceProgramCounter()
		
		if programCounter >= Self.MemorySize {
			throw ExecutionError.InvalidIndex(index: programCounter)
		}
		
		try execute(instruction: instruction)
	}
	
	func run() throws {
		quit = false
		while !quit {
			try executeNextInstruction()
		}
	}
	
	func getPixel(x: UInt16, y: UInt16) -> UInt8 {
		// TODO: extract display into a separate class
		display[x + y * Self.ResolutionWidth]
	}
	
	private func advanceProgramCounter() throws {
		// TODO: throw when out of bounds
		programCounter += 2
	}
	
	private func clearDisplay() {
		display.withUnsafeMutableBytes { ptr in
			_ = memset(ptr.baseAddress, 0, ptr.count)
		}
	}
	
	// MARK: - Execute instruction implementation
	private func executeSpecial(instruction: Instruction) throws {
		// TODO: extract special instruction codes
		switch instruction.b {
		case 0xe0:
			// clear screen
			clearDisplay()
		case 0xee:
			// return
			if let returnTo = stack.popLast() {
				programCounter = returnTo
			} else {
				quit = true
			}
		default:
			// sys call
			throw ExecutionError.NotSupported
		}
	}
	
	private func executeJump(instruction: Instruction) throws {
		// TODO: throw when accessing reserved memory
		programCounter = instruction.nnn
	}
	
	private func executeCall(instruction: Instruction) throws {
		// TODO: throw on stack under- and overflow
		stack.append(programCounter)
		programCounter = instruction.nnn
	}
	
	private func executeSkipIf(instruction: Instruction) throws {
		if registers[instruction.x] == instruction.b {
			try advanceProgramCounter()
		}
	}
	
	private func executeSkipIfNot(instruction: Instruction) throws {
		if registers[instruction.x] != instruction.b {
			try advanceProgramCounter()
		}
	}
	
	private func executeSkipIfRegister(instruction: Instruction) throws {
		if registers[instruction.x] == registers[instruction.y] {
			try advanceProgramCounter()
		}
	}
	
	private func executeSetRegister(instruction: Instruction) {
		registers[instruction.x] = instruction.b
	}
	
	private func executeAddToRegister(instruction: Instruction) {
		registers[instruction.x] &+= instruction.b
	}
	
	private func executeArithmetic(instruction: Instruction) throws {
		throw ExecutionError.NotSupported
	}
	
	private func executeSkipIfNotRegister(instruction: Instruction) throws {
		if registers[instruction.x] != registers[instruction.y] {
			try advanceProgramCounter()
		}
	}
	
	private func executeSetIndex(instruction: Instruction) {
		indexRegister = instruction.nnn
	}
	
	private func executeJumpMod(instruction: Instruction) throws {
		// TODO: implement an option to increment by registers[x]
		// TODO: throw when indexing into reserved memory
		programCounter = instruction.nnn + registers[0]
	}
	
	private func executeRandom(instruction: Instruction) {
		registers[instruction.x] = UInt8.random(in: 0..<UInt8.max) & instruction.b
	}
	
	private func executeDraw(instruction: Instruction) {
		let x = UInt16(registers[instruction.x]) % Self.ResolutionWidth
		let y = UInt16(registers[instruction.y]) % Self.ResolutionHeight
		
		let dy = min(UInt16(instruction.n), Self.ResolutionHeight - y)
		let dx = min(8, Self.ResolutionWidth - x)
		registers[0x0f] = 0
		
		for i in 0..<dy {
			let byte = memory[indexRegister + i]
			
			for j in 0..<dx {
				let bit = (byte >> (dx - j - 1)) & 0x01
				let index = (y + i) * Self.ResolutionWidth + x + UInt16(j)
				
				display[index] ^= bit
				registers[0x0f] = registers[0x0f] | bit & display[index]
			}
		}
	}
	
	private func executeSkipIfKey(instruction: Instruction) throws {
		switch instruction.b {
		case 0x9e:
			throw ExecutionError.NotSupported
		case 0xa1:
			throw ExecutionError.NotSupported
		default:
			throw ExecutionError.NotSupported
		}
	}
	
	private func executeExtended(instruction: Instruction) throws {
		switch instruction.b {
		case 0x07:
			registers[instruction.x] = delayTimer
		case 0x15:
			delayTimer = registers[instruction.x]
		case 0x18:
			soundTimer = registers[instruction.x]
		case 0x1e:
			indexRegister += UInt16(registers[instruction.x])
			if indexRegister >= 0x1000 {
				indexRegister &= 0x0fff
				// TODO: implement an option to skip flagging this overlow
				registers[0x0f] = 1
			}
		case 0x0a:
			throw ExecutionError.NotSupported
		case 0x29:
			indexRegister = Self.FontDataOffset + UInt16(registers[instruction.x] & 0x0f)
		case 0x33:
			let num = registers[instruction.x]
			memory[indexRegister] = num / 100
			memory[indexRegister + 1] = num / 10 % 10
			memory[indexRegister + 2] = num % 10
		case 0x55:
			// TODO: implement an option to increment/decrement index register
			// TODO: throw if writing into reserved memory
			for i in 0...instruction.x {
				memory[indexRegister + i] = registers[i]
			}
		case 0x65:
			// TODO: consider throwing if reading from reserved memory
			for i in 0...instruction.x {
				registers[i] = memory[indexRegister + i]
			}
		default:
			throw ExecutionError.NotSupported
		}
	}
}
