//
//  Instruction.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import Foundation

protocol EmulatorDelegate: AnyObject {
	func emulatorDidRender(
		_ emulator: Emulator,
		x: UInt16,
		y: UInt16,
		width: UInt16,
		height: UInt16
	)
}

class Emulator {
	static let ReservedMemorySize: UInt16 = 512
	static let MemorySize: UInt16 = 4096
	static let RegisterCount = 16
	// TODO: turn resolution into an option
	static let ResolutionHeight: UInt16 = 32
	static let ResolutionWidth: UInt16 = 64
	static let MaxStackSize: UInt16 = 16

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

	private (set) var memory = [UInt8](repeating: 0, count: Int(MemorySize))
	private (set) var display: BitScreen
	private (set) var registers = [UInt8](repeating: 0, count: RegisterCount)
	private (set) var keyboard = [UInt8](repeating: 0, count: 16)
	private (set) var programCounter: UInt16 = ReservedMemorySize
	private (set) var indexRegister: UInt16 = ReservedMemorySize
	private (set) var stack = [UInt16](repeating: 0, count: Int(MaxStackSize))
	private (set) var currentStack = 0
	private (set) var delayTimer: UInt8 = 0
	private (set) var soundTimer: UInt8 = 0
	private (set) var flags: EmulatorFlags = .cosmacVip

	weak var delegate: EmulatorDelegate?

	init(with flags: EmulatorFlags = .cosmacVip) {
		self.flags = flags
		display = BitScreen(width: Self.ResolutionWidth, height: Self.ResolutionHeight)
	}

	func reset() {
		indexRegister = Self.ReservedMemorySize
		programCounter = Self.ReservedMemorySize

		clearDisplay()
		stack.withUnsafeMutableBytes { ptr in
			_ = memset(ptr.baseAddress, 0, ptr.count)
		}
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

		currentStack = 0
		delayTimer = 0
		soundTimer = 0

		delegate?.emulatorDidRender(self, x: 0, y: 0, width: Self.ResolutionWidth, height: Self.ResolutionHeight)
	}

	func load(rom: [UInt8]) throws {
		guard !rom.isEmpty else {
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
	}

	func execute(instruction: Instruction) throws {
		switch instruction.group {
		case .special:
			try executeSpecial(instruction: instruction)
		case .jump:
			try executeJump(instruction: instruction)
		case .call:
			try executeCall(instruction: instruction)
		case .skipIf:
			try executeSkipIf(instruction: instruction)
		case .skipIfNot:
			try executeSkipIfNot(instruction: instruction)
		case .skipIfRegister:
			try executeSkipIfRegister(instruction: instruction)
		case .setRegister:
			executeSetRegister(instruction: instruction)
		case .addToRegister:
			executeAddToRegister(instruction: instruction)
		case .arithmetic:
			try executeArithmetic(instruction: instruction)
		case .skipIfNotRegister:
			try executeSkipIfNotRegister(instruction: instruction)
		case .setIndex:
			try executeSetIndex(instruction: instruction)
		case .jumpWithOffset:
			try executeJumpWithOffset(instruction: instruction)
		case .random:
			executeRandom(instruction: instruction)
		case .draw:
			executeDraw(instruction: instruction)
		case .skipIfKey:
			try executeSkipIfKey(instruction: instruction)
		case .extended:
			try executeExtended(instruction: instruction)
		}
	}

	func getPixel(x: UInt16, y: UInt16) -> UInt8 {
		display[x + y * Self.ResolutionWidth]
	}

	func set(key: UInt8, pressed state: Bool) throws {
		guard key < keyboard.count else {
			throw ExecutionError.NotSupported
		}
		keyboard[key] = state ? 1 : 0
	}

	func tickTimers() {
		if delayTimer > 0 {
			delayTimer -= 1
		}

		if soundTimer > 0 {
			soundTimer -= 1
		}
	}

	func advanceProgramCounter() throws {
		try ensureSafeIndexRange(programCounter + 2, withWidth: 2)
		programCounter += 2
	}

	private func ensureSafeIndexRange<Width: BinaryInteger>(
		_ index: UInt16,
		withWidth width: Width
	) throws {
		// TODO: find out if reserved memory is actually off-limits
		if index < Self.ReservedMemorySize {
			throw ExecutionError.InvalidIndex(index: index)
		}

		if index + UInt16(width) > Self.MemorySize {
			throw ExecutionError.InvalidIndexRange(start: index, end: index + UInt16(width) - 1)
		}
	}

	private func ensureSafeIndex(_ index: UInt16) throws {
		if index < Self.ReservedMemorySize || index >= Self.MemorySize {
			throw ExecutionError.InvalidIndex(index: index)
		}
	}

	private func clearDisplay() {
		display.reset()
		delegate?.emulatorDidRender(self, x: 0, y: 0, width: Self.ResolutionWidth, height: Self.ResolutionHeight)
	}

	// MARK: - Execute instruction implementation

	private func executeSpecial(instruction: Instruction) throws {
		switch instruction.specialCode {
		case .clearScreen:
			clearDisplay()
		case .popStack:
			if currentStack == 0 {
				throw ExecutionError.StackUnderflow
			}
			currentStack -= 1
			programCounter = stack[currentStack]
		default:
			// sys call
			throw ExecutionError.NotSupported
		}
	}

	private func executeJump(instruction: Instruction) throws {
		try ensureSafeIndex(instruction.nnn)
		programCounter = instruction.nnn
	}

	private func executeCall(instruction: Instruction) throws {
		if currentStack >= Self.MaxStackSize {
			throw ExecutionError.StackOverflow
		}
		try ensureSafeIndex(instruction.nnn)
		stack[currentStack] = programCounter
		programCounter = instruction.nnn
		currentStack += 1
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
		switch instruction.arithmeticCode {
		case .copy?:
			registers[instruction.x] = registers[instruction.y]
		case .or?:
			registers[instruction.x] |= registers[instruction.y]
		case .and?:
			registers[instruction.x] &= registers[instruction.y]
		case .xor?:
			registers[instruction.x] ^= registers[instruction.y]
		case .add?:
			let (res, over) = registers[instruction.x].addingReportingOverflow(registers[instruction.y])
			registers[instruction.x] = res
			registers[0x0f] = over ? 1 : 0
		case .subtract?:
			let (res, over) = registers[instruction.x].subtractingReportingOverflow(registers[instruction.y])
			registers[instruction.x] = res
			registers[0x0f] = over ? 0 : 1
		case .shiftRight?:
			if !flags.contains(.inPlaceShift) {
				registers[instruction.x] = registers[instruction.y]
			}
			registers[0x0f] = registers[instruction.x] & 0b0000_0001
			registers[instruction.x] >>= 1
		case .revSubtract?:
			let (res, over) = registers[instruction.y].subtractingReportingOverflow(registers[instruction.x])
			registers[instruction.x] = res
			registers[0x0f] = over ? 0 : 1
		case .shiftLeft?:
			if !flags.contains(.inPlaceShift) {
				registers[instruction.x] = registers[instruction.y]
			}
			registers[0x0f] = (registers[instruction.x] & 0b1000_0000) >> 7
			registers[instruction.x] <<= 1
		default:
			throw ExecutionError.NotSupported
		}
	}

	private func executeSkipIfNotRegister(instruction: Instruction) throws {
		if registers[instruction.x] != registers[instruction.y] {
			try advanceProgramCounter()
		}
	}

	private func executeSetIndex(instruction: Instruction) throws {
		try ensureSafeIndex(instruction.nnn)
		indexRegister = instruction.nnn
	}

	private func executeJumpWithOffset(instruction: Instruction) throws {
		let offset = flags.contains(.jumpWithOffsetBXNN)
			? registers[instruction.x]
			: registers[0]

		try ensureSafeIndex(programCounter + offset)
		programCounter = instruction.nnn + offset
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
				let bit = (byte >> (8 - j - 1)) & 0x01
				let index = (y + i) * Self.ResolutionWidth + x + UInt16(j)

				registers[0x0f] = registers[0x0f] | (bit & display[index])
				display[index] ^= bit
			}
		}

		delegate?.emulatorDidRender(self, x: x, y: y, width: dx, height: dy)
	}

	private func executeSkipIfKey(instruction: Instruction) throws {
		switch instruction.keyStateCode {
		case .pressed?:
			if keyboard[registers[instruction.x]] == 1 {
				try advanceProgramCounter()
			}
		case .notPressed?:
			if keyboard[registers[instruction.x]] == 0 {
				try advanceProgramCounter()
			}
		default:
			throw ExecutionError.NotSupported
		}
	}

	private func executeExtended(instruction: Instruction) throws {
		switch instruction.extendedCode {
		case .readDelayTimer?:
			registers[instruction.x] = delayTimer
		case .waitForKey?:
			if let i = keyboard.firstIndex(where: { $0 > 0 }) {
				registers[instruction.x] = UInt8(i)
			} else {
				programCounter -= 2
			}
		case .setDelayTimer?:
			delayTimer = registers[instruction.x]
		case .setSoundTimer?:
			soundTimer = registers[instruction.x]
		case .addToIndex?:
			indexRegister += UInt16(registers[instruction.x])
			if indexRegister >= 0x1000 {
				indexRegister &= 0x0fff
				if !flags.contains(.flaglessIndexOverflow) {
					registers[0x0f] = 1
				}
			}
			try ensureSafeIndex(indexRegister)
		case .indexToChar?:
			indexRegister = Self.FontDataOffset + UInt16(registers[instruction.x] & 0x0f) * 5
		case .bcd:
			try ensureSafeIndexRange(indexRegister, withWidth: 3)
			let num = registers[instruction.x]
			memory[indexRegister] = num / 100
			memory[indexRegister + 1] = num / 10 % 10
			memory[indexRegister + 2] = num % 10
		case .storeRegisters:
			try ensureSafeIndexRange(indexRegister, withWidth: instruction.x)
			for i in 0...instruction.x {
				memory[indexRegister + i] = registers[i]
			}
			if flags.contains(.incrementIndexOnStore) {
				indexRegister += UInt16(instruction.x)
			}
		case .loadRegisters:
			try ensureSafeIndexRange(indexRegister, withWidth: instruction.x)
			for i in 0...instruction.x {
				registers[i] = memory[indexRegister + i]
			}
			if flags.contains(.incrementIndexOnStore) {
				indexRegister += UInt16(instruction.x)
			}
		default:
			throw ExecutionError.NotSupported
		}
	}
}
