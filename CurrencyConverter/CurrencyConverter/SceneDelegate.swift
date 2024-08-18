//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import XCoordinator
import BackgroundTasks

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let router = UserListCoordinator().strongRouter
    private let backgroundTaskManager: BackgroundTaskManagerType = BackgroundTaskManager()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        router.setRoot(for: window ?? UIWindow())
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        backgroundTaskManager.scheduleTask()
    }
}


