//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let viewController = ConverterScreenViewController(viewModel: ConverterScreenViewModel())
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}


