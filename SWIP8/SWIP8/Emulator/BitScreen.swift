//
//  BitScreen.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 09.10.2021.
//

import Foundation

struct BitScreen: Screen, Sequence {
	private var buffer: [UInt8]

	private (set) var width: UInt16

	private (set) var height: UInt16

	init(width: UInt16, height: UInt16) {
		self.width = width
		self.height = height
		buffer = [UInt8](repeating: 0, count: Int(width * height))
	}

	subscript(index: UInt16) -> UInt8 {
		get {
			buffer[index]
		}
		set {
			buffer[index] = newValue
		}
	}

	mutating func reset() {
		buffer.withUnsafeMutableBytes { ptr in
			_ = memset(ptr.baseAddress, 0, ptr.count)
		}
	}

	func makeIterator() -> IndexingIterator<[UInt8]> {
		buffer.makeIterator()
	}
}
