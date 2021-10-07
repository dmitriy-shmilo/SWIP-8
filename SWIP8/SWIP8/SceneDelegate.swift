//
//  SceneDelegate.swift
//  SWIP8
//
//  Created by Dmitriy Shmilo on 03.10.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard (scene as? UIWindowScene) != nil else { return }
	}
}
