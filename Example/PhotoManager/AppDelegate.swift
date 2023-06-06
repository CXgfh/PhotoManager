//
//  AppDelegate.swift
//  PhotoManager
//
//  Created by oauth2 on 04/18/2023.
//  Copyright (c) 2023 oauth2. All rights reserved.
//

import UIKit
import PhotoManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var mask: UIInterfaceOrientationMask = .all


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        PhotoManager.sharde.setup()
        PhotoManager.sharde.delegate.add(self)
        return true
    }
}

extension AppDelegate: PhotoManagerDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return mask
    }
    
    func photoManagerSpecifiedScreen(_ mask: UIInterfaceOrientationMask) {
        self.mask = mask
    }
    
    func photoManagerUnlockTheScreen() {
        mask = .all
    }
    
    func photoManagerLockTheScreen() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            mask = .portrait
        case .landscapeLeft:
            mask = .landscapeLeft
        case .portraitUpsideDown :
            mask = .portraitUpsideDown
        case .landscapeRight:
            mask = .landscapeRight
        default:
            mask = .all
        }
    }
}
