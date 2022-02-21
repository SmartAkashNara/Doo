//
//  SceneDelegate.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

var IS_USER_INSIDE_APP = false // Indicates user is in initial startup page, available to handle deeplinks, push notifications, learning journey flow etc...

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static var getWindow: UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let sceneDelegate = windowScene.delegate as? SceneDelegate{
            return sceneDelegate.window
        }else{
            return nil
        }
    }
    

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

//        SceneDelegate.getWindow?.rootViewController = UIStoryboard.menu.linkWithAlexaVC
//        return

        if let certifUser = UserManager.getCertifUser() {
            debugPrint("Got User!")
            APP_USER = certifUser
            if let user = APP_USER, let accessToken = user.accessToken {
                NetworkingManager.shared.setAuthorization(accessToken)
                 print("access token: \(accessToken)")
                 self.window?.rootViewController = UIStoryboard.dooTabbar.instantiateViewController(identifier: "SplashViewController")
                
//                if let userActivity = connectionOptions.userActivities.first {
//                    if let objIntent = userActivity.interaction?.intent as? SceneExecutionIntent {
//                        print(userActivity)
//                        let id = Int(truncating: objIntent.sceneId ?? 0)
//                        if id == 0 {
//                            return
//                        }
//                        self.excuteSceneApi(id: id)
//                    }
//                }
                
//                if let userActivity = connectionOptions.userActivities.first {
//                    if let objIntent = userActivity.interaction?.intent as? ApplianceActionsBasicIntent {
//                        print(userActivity)
//                        if objIntent.applianceId == 0 || objIntent.endpointId == 0 {
//                            return
//                        }
////                        self.callApplienceONOFFAPI(objApplianceIntent: objIntent)
//                    }
//                }
                
                if let userActivity = connectionOptions.userActivities.first {
                    if let objIntent = userActivity.interaction?.intent as? ApplianceActionRgbIntent {
                        print(userActivity)
                        print("navigation fore rgb")
                        if objIntent.applianceId == 0 || objIntent.endpointId == 0 {
                            return
                        }
//                        let storyBoard: UIStoryboard = UIStoryboard(name: "Siri", bundle: nil)
//                        let vc = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//
                        guard let destView = UIStoryboard.group.applianceDetailInGroupVC else { return }
                        
                        
                        print("HIIIIIIIIIII")
//                        destView.hidesBottomBarWhenPushed = true
////                        destView.deviceDetails = self.selectedGroupDetails?.devices[section]
////                        destView.selectedApplinceRow = row
////                        destView.groupEnableDisable = self.selectedGroupDetails?.enable ?? false
//                        self.window?.rootViewController?.navigationController?.pushViewController(destView, animated: true)
                        
                        
//                        self.callApplienceONOFFAPI(objApplianceIntent: objIntent)
                    }
                }
                
                
            }else{
                self.window?.rootViewController = UIStoryboard.onboarding.instantiateInitialViewController()
            }
        }else{
            self.window?.rootViewController = UIStoryboard.onboarding.instantiateInitialViewController()
        }
        return
        
    }
    
    func excuteSceneApi(id:Int) {
        let param: [String: Any] = ["id":id]
        
        // API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .excuteScene(param),method: .put) { (parsingResponse) in
            // API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
        debugPrint("sceneDidDisconnect")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        debugPrint("Did become active called")
        // if user available, then connect
        
        if let user = APP_USER,
           let macAddress = user.selectedEnterprise?.enterpriseGateway?.macAddress,
           !macAddress.isEmpty{
            MQTTSwift.shared.subscribeMQTT(macAddress: macAddress) // MQTT External Code.
            deepLinkingRedirection()
        }else{
            (TABBAR_INSTANCE as? DooTabbarViewController)?.refreshHomeView() // refresh home view....
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        debugPrint("Did become active called")
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        debugPrint("sceneWillEnterForeground")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: REFRESH_SCENE_LIST_TO_CHECK_SIRI_SHORTCUTS), object: nil)
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        if let _ = COUNT_DOWN_VIEW {
            // debugPrint("count down view detected...")
            self.setCountdownBasedOnAppSpentTimeInBackground()
        }
        
        
        if let navigationVC = self.window?.rootViewController as? UINavigationController,
           let _ = navigationVC.viewControllers.first as? AddEnterpriseWhenNotAvailableViewController {
            // Change to splash to check that user has been enabled for any enterprise.
            // This will show case splash for while and still user don't have any enterprise, then again it will show add enterprise full screen.
            self.window?.rootViewController = UIStoryboard.dooTabbar.instantiateViewController(identifier: "SplashViewController")
        }else if let tabbarVC = self.window?.rootViewController as? UITabBarController as? DooTabbarViewController{
            tabbarVC.informViewsToUpdate(atIndex: DooTabs.menu.rawValue)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        debugPrint("sceneDidEnterBackground")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        if let _ = COUNT_DOWN_VIEW {
            // debugPrint("count down view detected...")
            self.setTimeOfAppWentInBackground()
        }
    }
    
    
    func callApplienceONOFFAPI(objApplianceIntent: ApplianceActionsBasicIntent) {
        // Continue only if group is enabled...
        
        let applienceValue = objApplianceIntent.value
        
        let param: [String:Any] = [
            "applianceId": objApplianceIntent.applianceId ?? 0,
            "endpointId": objApplianceIntent.endpointId ?? 0,
            "applianceData": ["action": EnumApplianceAction.onOff.rawValue, "value": applienceValue] // here passed action static 1 for on off only
        ]
        
        // API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .applienceONOFF, method:.post) { (parsingResponse) in
            debugPrint("REst Api Response:", parsingResponse!)
        } failureInform: {
        }
    }
    
    
    // ADDITIONAL PROPERTIES
    private let defaults: UserDefaults = UserDefaults.init()
}

// MARK: COUT DOWN WORK
extension SceneDelegate {
    func setTimeOfAppWentInBackground(withKey key: String = "TimeEnterBackground") {
        defaults.set(Date(), forKey: key)
        defaults.synchronize()
    }

    func setCountdownBasedOnAppSpentTimeInBackground() {
        
        func getElapsedTime() -> Int {
            if let timeSpentInBackground = defaults.value(forKey: "TimeEnterBackground") as? Date {
                let elapsed = Int(Date().timeIntervalSince(timeSpentInBackground))
                return elapsed
            }
            return 0
        }
        
        COUNT_DOWN_VIEW?.count -= getElapsedTime()
    }
}

// UserActivity
extension SceneDelegate{
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        debugPrint("")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,let url = userActivity.webpageURL{
            self.handleUniversalLink(url: url)
        }
    }
    
    func handleUniversalLink(url: URL) {
        Deeplinker.handleDeeplink(url: url)
        deepLinkingRedirection()
    }
    
    func deepLinkingRedirection() {
        switch Deeplinker.getDeepLinkType(){
        case .authSignin:
            // When user kills the app, this will instantly navigate to deeplink without any rootview. which is incorrect.
            if IS_USER_INSIDE_APP {
                Deeplinker.checkDeepLink()
            }
        default:break
        }
    }

}
