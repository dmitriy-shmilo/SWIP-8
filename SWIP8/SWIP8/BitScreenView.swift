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

	var bitScreen: BitScreen? {
		didSet {
			setupScreen()
		}
	}

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

		guard let bitScreen = bitScreen else {
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

		ctx.setFillColor(cgBackground)
		ctx.fill(rect)

		ctx.setFillColor(cgPixOff)
		ctx.fill(
			CGRect(
				x: horizontalOffset,
				y: verticalOffset,
				width: bitSize * cgResolutionWidth,
				height: bitSize * cgResolutionHeight
			).intersection(rect)
		)

		let rects = bitScreen.enumerated()
			.filter {
				$0.1 != 0
			}
			.map {
				(x: UInt16($0.0) % bitScreen.width, y: UInt16($0.0) / bitScreen.width)
			}
			.map {
				CGRect(
					x: CGFloat($0.x) * bitSize + horizontalOffset,
					y: CGFloat($0.y) * bitSize + verticalOffset,
					width: bitSize,
					height: bitSize
				)
			}
			.filter {
				$0.intersects(rect)
			}
		ctx.beginPath()
		ctx.addRects(rects)
		ctx.setFillColor(cgPixOn)
		ctx.fillPath()
	}

	private func setup() {
		setupColors()
		setupScreen()
	}

	private func setupScreen() {
		guard let bitScreen = bitScreen else {
			return
		}

		cgResolutionWidth = CGFloat(bitScreen.width)
		cgResolutionHeight = CGFloat(bitScreen.height)
	}

	private func setupColors() {
		cgBackground = backgroundColor?.cgColor ?? Self.DefaultBackgroundColor.cgColor
		cgPixOn = pixelOnColor.cgColor
		cgPixOff = pixelOffColor.cgColor
	}
}
