//
//  Emulator+Run.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 18.10.2021.
//

import Foundation

extension Emulator {
	func peekInstruction() -> Instruction {
		Instruction(a: memory[programCounter], b: memory[programCounter + 1])
	}

	func executeNextInstruction() throws {
		let instruction = peekInstruction()
		try advanceProgramCounter()

		try execute(instruction: instruction)
	}

	func run() throws {
		var quit = false
		var timers = 0.0
		while !quit {
			timers += 1.0 / 700.0
			if timers >= 1.0 / 60.0 {
				timers += 0.0
				tickTimers()
			}
			try executeNextInstruction()

			// TODO: decouple from Thread
			Thread.sleep(forTimeInterval: 1 / 700.0)
			if Thread.current.isCancelled {
				quit = true
			}
		}
	}
}
