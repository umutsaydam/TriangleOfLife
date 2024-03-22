//
//  AppDelegate.swift
//  TriangleOfLife
//
//  Created by Yunus Emre Berdibek on 8.03.2024.
//

import UIKit

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: HomeViewController())
        self.window = window
        self.window?.makeKeyAndVisible()
        return true
    }
}
