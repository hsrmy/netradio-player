//
//  AppDelegate.swift
//  netradio player
//
//  Created by hsrmy on 2018/10/4.
//  Copyright © 2018 hsrmy. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var agqrinfo: [String:[[String]]]!
    var onseninfo: [String:[[String]]]!
    var hibikiInfo: [String:[[String]]]!
    let picarray = UserDefaults.standard.dictionary(forKey: "picarray")
    var player: AVPlayer?
    var controller: AVPlayerViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let navbarController: UINavigationController? = UINavigationController(rootViewController: LaunchScreenController())
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navbarController
        self.window?.makeKeyAndVisible()
        
        let NavigationDrawer = UISideMenuNavigationController(rootViewController: DrawerMenuController())
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuWidth = max(round(min((UIScreen.main.bounds.width/2), (UIScreen.main.bounds.height/2))), 240)
        SideMenuManager.default.menuLeftNavigationController = NavigationDrawer
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch let error as NSError {
            print(error)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       self.controller?.player = nil
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.controller?.player = self.player
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        guard let viewController = self.visibleViewController else { return true }
        return viewController.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let viewController = self.visibleViewController else { return .all }
        return viewController.supportedInterfaceOrientations
    }
}
