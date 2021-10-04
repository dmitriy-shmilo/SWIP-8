//
//  Array+ByteIndexable.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import Foundation

protocol ByteIndexable {
	associatedtype Element
	associatedtype SubSequence
	
	subscript(byte: UInt8) -> Element { get set }
	subscript(range: Range<UInt8>) -> SubSequence { get }
}

extension Array: ByteIndexable {
	subscript(byte: UInt8) -> Element {
		get {
			self[Int(byte)]
		}
		set {
			self[Int(byte)] = newValue
		}
	}
	
	subscript(range: Range<UInt8>) -> SubSequence {
		self[Int(range.startIndex)..<Int(range.endIndex)]
	}
}
