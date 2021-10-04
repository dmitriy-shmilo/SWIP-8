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
		
		clearScreen()
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
	
	func load(rom: [UInt8]) {
		// TODO: throw an error instead of crashing
		guard rom.count < Self.MemorySize - Self.ReservedMemorySize else {
			fatalError("Rom size is larger than memory allows.")
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
	
	func load(string: String) {
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
				fatalError("Unknown character \(char)")
			}
		}
		load(rom: bytes)
	}
	
	func execute(instruction: Instruction) {
		switch instruction.group {
		case .Special where instruction.b == 0xe0:
			clearScreen()
		case .Special where instruction.b == 0xee:
			if let returnTo = stack.popLast() {
				programCounter = returnTo
			} else {
				quit = true
			}
		case .Special:
			fatalError("Jump to machine code isn't supported")
		case .Jump:
			programCounter = instruction.nnn
		case .Call:
			// TODO: prevent stack from growing too tall
			stack.append(programCounter)
			programCounter = instruction.nnn
		case .SkipIf:
			if registers[instruction.x] == instruction.b {
				programCounter += 2
			}
		case .SkipIfNot:
			if registers[instruction.x] != instruction.b {
				programCounter += 2
			}
		case .SkipIfRegister:
			if registers[instruction.x] == registers[instruction.y] {
				programCounter += 2
			}
		case .SetRegister:
			registers[instruction.x] = instruction.b
		case .AddToRegister:
			registers[instruction.x] &+= instruction.b
		case .Arithmetic:
			fatalError("Boolean and arithmetic operations aren't implemented")
		case .SkipIfNotRegister:
			if registers[instruction.x] == registers[instruction.y] {
				programCounter += 2
			}
		case .SetIndex:
			indexRegister = instruction.nnn
		case .JumpMod:
			// TODO: implement an option to increment by registers[x]
			programCounter = instruction.nnn + registers[0]
		case .Random:
			registers[instruction.x] = UInt8.random(in: 0..<UInt8.max) & instruction.b
		case .Draw:
			draw(x: registers[instruction.x], y: registers[instruction.y], rows: instruction.n)
		case .SkipIfKey where instruction.b == 0x9e:
			fatalError("Skip if key pressed isn't implemented")
		case .SkipIfKey where instruction.b == 0xa1:
			fatalError("Skip if key not pressed isn't implemented")
		case .Extended where instruction.b == 0x07:
			registers[instruction.x] = delayTimer
		case .Extended where instruction.b == 0x15:
			delayTimer = registers[instruction.x]
		case .Extended where instruction.b == 0x18:
			soundTimer = registers[instruction.x]
		case .Extended where instruction.b == 0x1e:
			indexRegister += UInt16(registers[instruction.x])
			if indexRegister >= 0x1000 {
				indexRegister &= 0x0fff
				// TODO: implement an option to skip flagging this overlow
				registers[0x0f] = 1
			}
		case .Extended where instruction.b == 0x0a:
			fatalError("Get key instruction isn't implemented")
		case .Extended where instruction.b == 0x29:
			indexRegister = Self.FontDataOffset + UInt16(registers[instruction.x] & 0x0f)
		case .Extended where instruction.b == 0x33:
			let num = registers[instruction.x]
			memory[indexRegister] = num / 100
			memory[indexRegister + 1] = num / 10 % 10
			memory[indexRegister + 2] = num % 10
		case .Extended where instruction.b == 0x55:
			// TODO: implement an option to increment/decrement index register
			for i in 0...instruction.x {
				memory[indexRegister + i] = registers[i]
			}
		case .Extended where instruction.b == 0x65:
			for i in 0...instruction.x {
				registers[i] = memory[indexRegister + i]
			}
		default:
			fatalError("Unknown instruction: \(instruction)")
		}
	}
	
	func peekInstruction() -> Instruction {
		Instruction(a: memory[programCounter], b: memory[programCounter + 1])
	}
	
	func executeNextInstruction() {
		let instruction = peekInstruction()
		programCounter += 2
		
		if programCounter >= Self.MemorySize {
			fatalError("PC (\(programCounter)) indexes out of memory.")
		}
		
		execute(instruction: instruction)
	}
	
	// TODO: throw errors instead of crashing
	func run() {
		quit = false
		while !quit {
			executeNextInstruction()
		}
	}
	
	private func clearScreen() {
		display.withUnsafeMutableBytes { ptr in
			_ = memset(ptr.baseAddress, 0, ptr.count)
		}
	}
	
	private func draw(x: UInt8, y: UInt8, rows: UInt8) {
		let x = UInt16(x) % Self.ResolutionWidth
		let y = UInt16(y) % Self.ResolutionHeight
		
		let dy = min(UInt16(rows), Self.ResolutionHeight - y)
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
}
