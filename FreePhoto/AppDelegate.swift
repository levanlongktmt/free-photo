//
//  AppDelegate.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/20/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var locationHelper = LocationHelper()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BaseConnector.currentConenctor = FlickrConnector()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        let rootVc = PhotoGridViewController()
        let nav = UINavigationController(rootViewController: rootVc)
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.isOpaque = false
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }


}

