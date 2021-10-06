//
//  EmulatorError.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import Foundation

protocol EmulationError: Error {
	
}

enum LoadError: EmulationError {
	case Unknown
	case NotEnoughMemory
	case InvalidCharacter(string: String)
	case InvalidInputLength
}

enum ExecutionError: EmulationError {
	case Unknown
	case NotSupported
	case InvalidIndex(index: UInt16)
	case InvalidIndexRange(start: UInt16, end: UInt16)
	case StackOverflow
	case StackUnderflow
}
