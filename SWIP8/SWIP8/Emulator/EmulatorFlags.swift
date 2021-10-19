//
//  EmulatorFlags.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 19.10.2021.
//

import Foundation

struct EmulatorFlags: OptionSet {
	var rawValue: UInt64

	static let inPlaceShift = EmulatorFlags(rawValue: 1 << 0)
	static let flaglessIndexOverflow = EmulatorFlags(rawValue: 1 << 1)
	static let incrementIndexOnStore = EmulatorFlags(rawValue: 1 << 2)
	static let jumpWithOffsetBXNN = EmulatorFlags(rawValue: 1 << 3)

	static let cosmacVip: EmulatorFlags = [flaglessIndexOverflow, incrementIndexOnStore]
	static let chip48: EmulatorFlags = [flaglessIndexOverflow, inPlaceShift, jumpWithOffsetBXNN]
}
