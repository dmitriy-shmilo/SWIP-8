//
//  Screen.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 09.10.2021.
//

import Foundation

protocol Screen {
	associatedtype PixelType
	associatedtype DimensionType

	var width: DimensionType {
		get
	}

	var height: DimensionType {
		get
	}

	subscript(index: DimensionType) -> PixelType {
		get
		set
	}

	mutating func reset()
}

extension Screen where DimensionType: BinaryInteger {
	var count: DimensionType {
		width * height
	}
}

extension Screen where DimensionType == UInt16 {

	subscript(index: UInt8) -> PixelType {
		get {
			self[UInt16(index)]
		}
		set {
			self[UInt16(index)] = newValue
		}
	}

	subscript(index: (x: UInt16, y: UInt16)) -> PixelType {
		get {
			self[UInt16(index.x + index.y * width)]
		}
		set {
			self[UInt16(index.x + index.y * width)] = newValue
		}
	}

	subscript(index: (x: UInt8, y: UInt8)) -> PixelType {
		get {
			self[UInt16(index.x) + UInt16(index.y) * width]
		}
		set {
			self[UInt16(index.x) + UInt16(index.y) * width] = newValue
		}
	}
}
