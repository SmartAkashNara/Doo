//
//  AppDelegate.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var userManager: UserManager? = UserManager.init()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        debugPrint("did finish launching with options called!")
        SSReachabilityManager.shared.startMonitoring() // Start checking internet connection
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let interaction = userActivity.interaction,
            let response = interaction.intentResponse as? SceneExecutionIntentResponse,
            let responseActivityScene = response.userActivity,
            let intentScene = interaction.intent as? SceneExecutionIntent else {
                return false
        }
        
        guard let interaction = userActivity.interaction,
            let response = interaction.intentResponse as? ApplianceActionsBasicIntentResponse,
            let responseActivityBasic = response.userActivity,
            let intentBasic = interaction.intent as? ApplianceActionsBasicIntent else {
                return false
        }
        
        guard let interaction = userActivity.interaction,
            let response = interaction.intentResponse as? ApplianceActionSpeedIntentResponse,
            let responseActivitySpeed = response.userActivity,
            let intentSpeed = interaction.intent as? ApplianceActionSpeedIntent else {
                return false
        }
        
        guard let interaction = userActivity.interaction,
            let response = interaction.intentResponse as? ApplianceActionRgbIntentResponse,
            let responseActivityRgb = response.userActivity,
            let intentRgb = interaction.intent as? ApplianceActionRgbIntent else {
                return false
        }
        
        print("navigation for rgb: \(intentRgb)")
        
      return false
    }    
}
