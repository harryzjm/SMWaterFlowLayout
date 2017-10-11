//
//  AppDelegate.swift
//  Demo
//
//  Created by 叶落沉香 on 11/10/2017.
//  Copyright © 2017 Magic. All rights reserved.
//

import UIKit
import SMWaterFlowLayout

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController(collectionViewLayout: SMWaterFlowLayout())
        window?.rootViewController = UINavigationController(rootViewController: vc)
        window?.makeKeyAndVisible()

        return true
    }

}
