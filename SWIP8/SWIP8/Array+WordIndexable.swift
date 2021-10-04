//
//  Array+WordIndexable.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import Foundation

protocol WordIndexable {
	associatedtype Element
	associatedtype SubSequence

	subscript(byte: UInt16) -> Element { get set }
	subscript(range: Range<UInt16>) -> SubSequence { get }
}

extension Array: WordIndexable {
	subscript(word: UInt16) -> Element {
		get {
			self[Int(word)]
		}
		set {
			self[Int(word)] = newValue
		}
	}
	
	subscript(range: Range<UInt16>) -> SubSequence {
		self[Int(range.startIndex)..<Int(range.endIndex)]
	}
}
