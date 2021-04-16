//
//  AppDelegate.swift
//  UnicodeEmojiExample
//
//  Created by German on 16/4/21.
//  Copyright © 2021 Rootstrap. All rights reserved.
//

import UIKit
import UnicodeEmoji

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        EmojiLoader.shared.preload()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateInitialViewController()
        window?.makeKeyAndVisible()

        return true
    }

}

