//
//  SceneDelegate.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 30.10.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: scene)
        self.window = window

        let networkManager = NetworkManager()
        let imageCacheManager = ImageCacheManager()
        let userDefaultsManager = UserDefaultsManager()

        let viewController = JobListViewController()
        let presenter = JobListPresenter(view: viewController, networkManager: networkManager, imageCacheManager: imageCacheManager, userDefaultsManager: userDefaultsManager)

        viewController.presenter = presenter


        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()
    }
}

