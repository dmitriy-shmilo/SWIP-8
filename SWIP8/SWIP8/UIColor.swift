//
//  UIColor.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import UIKit
import CoreGraphics

extension UIColor {
	func inverseColor () -> UIColor {
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 0.0

		if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
			return .init(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
		}
		return .init(white: 0.0, alpha: 1.0)
	}

	func inverseCGColor () -> CGColor {
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 0.0

		if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
			return .init(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
		}
		return .init(gray: 0.0, alpha: 1.0)
	}
}
