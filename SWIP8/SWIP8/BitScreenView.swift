//
//  BitScreenView.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 04.10.2021.
//

import UIKit

@IBDesignable
class BitScreenView: UIView {
	private static let DefaultBackgroundColor: UIColor = .systemBackground
	// TODO: create a screen struct
	var bitScreen = [UInt8]()
	@IBInspectable
	var resolutionWidth: Int = 64
	@IBInspectable
	var resoltionHeight: Int = 32
	@IBInspectable
	var pixelOnColor: UIColor = .white
	@IBInspectable
	var pixelOffColor: UIColor = .black
	
	private var cgBackground: CGColor!
	private var cgPixOn: CGColor!
	private var cgPixOff: CGColor!
	private var cgResolutionWidth: CGFloat!
	private var cgResolutionHeight: CGFloat!

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	override func awakeFromNib() {
		setup()
	}
	
	override func draw(_ rect: CGRect) {
		guard let ctx = UIGraphicsGetCurrentContext() else {
			return
		}
		
		guard bitScreen.count >= resolutionWidth * resoltionHeight else {
			return
		}
		
		// TODO: re-calculate sizes and offsets only when bounds change
		let bitSize = min(
			bounds.size.width / cgResolutionWidth,
			bounds.size.height / cgResolutionHeight
		)
		
		let fieldWidth = bitSize * cgResolutionWidth
		let fieldHeight = bitSize * cgResolutionHeight
		let verticalOffset = bounds.size.height / 2 - fieldHeight / 2
		let horizontalOffset = bounds.size.width / 2 - fieldWidth / 2
		
		// TODO: redraw only the portion specified by rect
		ctx.setFillColor(cgBackground)
		ctx.fill(bounds)
		
		for y in 0..<resoltionHeight {
			for x in 0..<resolutionWidth {
				if bitScreen[x + y * resolutionWidth] == 0 {
					ctx.setFillColor(cgPixOff)
				} else {
					ctx.setFillColor(cgPixOn)
				}
				
				ctx.fill(CGRect(
					x: CGFloat(x) * bitSize + horizontalOffset,
					y: CGFloat(y) * bitSize + verticalOffset,
					width: bitSize,
					height: bitSize))
			}
		}
	}
	
	private func setup() {
		cgBackground = backgroundColor?.cgColor ?? Self.DefaultBackgroundColor.cgColor
		cgPixOn = pixelOnColor.cgColor
		cgPixOff = pixelOffColor.cgColor
		cgResolutionWidth = CGFloat(resolutionWidth)
		cgResolutionHeight = CGFloat(resoltionHeight)
	}
}
