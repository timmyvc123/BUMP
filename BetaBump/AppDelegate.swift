//
//  AppDelegate.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var hasAlreadyLaunched: Bool!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let defaults = UserDefaults.standard
        let likesPlayListId = ["likesPlaylistId" : ""]
        let superLikesPlaylistId = ["superLikesPlaylistId" : ""]
        defaults.register(defaults: likesPlayListId)
        defaults.register(defaults: superLikesPlaylistId)
        
        hasAlreadyLaunched = UserDefaults.standard.bool(forKey: "hasAlreadyLaunched")
        
        if (hasAlreadyLaunched) {
            hasAlreadyLaunched = true
        } else {
            UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
        }
        
        return true
    }
    
    func sethasAlreadyLaunched() {
        hasAlreadyLaunched = true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }


}

