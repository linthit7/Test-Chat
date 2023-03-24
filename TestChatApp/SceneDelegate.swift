//
//  SceneDelegate.swift
//  TestChatApp
//
//  Created by Lin Thit Khant on 3/22/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        let rootViewController = ChatViewController()
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            let navigationController = UINavigationController(rootViewController: rootViewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
    }

}

