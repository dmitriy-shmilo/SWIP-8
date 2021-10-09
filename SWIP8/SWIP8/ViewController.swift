//
//  ViewController.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import UIKit

class ViewController: UIViewController, EmulatorDelegate {

	// pong program, taken from https://github.com/loktar00/chip8/tree/master/roms
	private static let rom = """
22f6 6b0c 6c3f 6d0c a2ea dab6 dcd6 6e00
22d4 6603 6802 6060 f015 f007 3000 121a
c717 7708 69ff a2f0 d671 a2ea dab6 dcd6
6001 e0a1 7bfe 6004 e0a1 7b02 601f 8b02
dab6 600c e0a1 7dfe 600d e0a1 7d02 601f
8d02 dcd6 a2f0 d671 8684 8794 603f 8602
611f 8712 4600 1278 463f 1282 471f 69ff
4700 6901 d671 122a 6802 6301 8070 80b5
128a 68fe 630a 8070 80d5 3f01 12a2 6102
8015 3f01 12ba 8015 3f01 12c8 8015 3f01
12c2 6020 f018 22d4 8e34 22d4 663e 3301
6603 68fe 3301 6802 1216 79ff 49fe 69ff
12c8 7901 4902 6901 6004 f018 7601 4640
76fe 126c a2f2 fe33 f265 f129 6414 6500
d455 7415 f229 d455 00ee 8080 8080 8080
8000 0000 0000 6b20 6c00 a2ea dbc1 7c01
3c20 12fc 6a00 00ee
"""

	@IBOutlet var screenView: BitScreenView!
	private let emu = Emulator()
	private var emuThread: Thread?

	override func viewDidLoad() {
		super.viewDidLoad()
		do {
			emu.delegate = self
			try emu.load(string: Self.rom)
			screenView.bitScreen = emu.display
		} catch {
			print(error)
		}

		emuThread = Thread(block: { [weak emu] in
			do {
				try emu?.run()
			} catch {
				print(error)
			}
		})
		emuThread!.start()
	}

	override func viewWillDisappear(_ animated: Bool) {
		emuThread?.cancel()
	}

	func emulatorDidRender(_ emulator: Emulator) {
		// TODO: prevent array copies
		screenView.bitScreen = emulator.display
		// TODO: pass an invalidated rectangle only
		DispatchQueue.main.async { [weak self] in
			self?.screenView.setNeedsDisplay()
		}
	}

	@IBAction private func buttonDown(_ sender: UIButton) {
		// TODO: implement a thread-safe event queue
		try? emu.set(key: UInt8(sender.tag), pressed: true)
	}

	@IBAction private func buttonUp(_ sender: UIButton) {
		try? emu.set(key: UInt8(sender.tag), pressed: false)
	}
}
