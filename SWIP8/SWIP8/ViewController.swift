//
//  ViewController.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import UIKit

class ViewController: UIViewController, EmulatorDelegate {

	@IBOutlet var screenView: BitScreenView!
	private let emu = Emulator()
	private var emuThread: Thread?

	override func viewDidLoad() {
		super.viewDidLoad()
		do {
			emu.delegate = self
			// load IBM logo
			try emu.load(string: """
00e0 a22a 600c 6108 d01f 7009 a239 d01f
a248 7008 d01f 7004 a257 d01f 7008 a266
d01f 7008 a275 d01f 1228 ff00 ff00 3c00
3c00 3c00 3c00 ff00 ffff 00ff 0038 003f
003f 0038 00ff 00ff 8000 e000 e000 8000
8000 e000 e000 80f8 00fc 003e 003f 003b
0039 00f8 00f8 0300 0700 0f00 bf00 fb00
f300 e300 43e0 00e0 0080 0080 0080 0080
00e0 00e0
""")
		}
		catch {
			print(error)
		}

		emuThread = Thread(block: { [weak emu] in
			do {
				try emu?.run()
			}
			catch {
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
}
