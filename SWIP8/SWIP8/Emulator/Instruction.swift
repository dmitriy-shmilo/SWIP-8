//
//  Instruction.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import Foundation

struct Instruction {
	let a: UInt8
	let b: UInt8
	
	init(a: UInt8, b: UInt8) {
		self.a = a
		self.b = b
	}

	var o: UInt8 {
		a >> 4
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
