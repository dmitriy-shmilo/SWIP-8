//
//  UInt16.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import Foundation

extension UInt16 {
	static func + (a: UInt16, b: UInt8) -> UInt16 {
		a + UInt16(b)
	}
}
