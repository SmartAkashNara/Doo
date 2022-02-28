//
//  SplashViewModel.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 25/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class SplashViewModel {
    
    var userInfo: AppUser? = nil
    var accessToken: String? = nil // SignUp....
    var doWaitForAnimation: Bool = true // When user is from login, don't wait for animation.
    
    var isProfileInfoAPICompleted: Bool = false {
        didSet {
            if isAnimationCompleted {
                self.redirectToAddEnterpriseIfNotAvailableOrRedirectToHome()
            }
        }
    }
    var isAnimationCompleted: Bool = false {
        didSet {
            if isProfileInfoAPICompleted {
                self.redirectToAddEnterpriseIfNotAvailableOrRedirectToHome()
            }
        }
    }
    
    // When session config required... Currently not used. Profile used which has been implemented in extension.
    func callFetchSessionInfo(success: (()->())? = nil) {
        
        self.isProfileInfoAPICompleted = false // make it false first.
        
        API_LOADER.show(animated: false)
        API_SERVICES.callAPI(path: .getUserSessionInfo, method:.get) { (parsingResponse) in
            API_LOADER.dismiss(animated: false)
            print("Session response: \(String(describing: parsingResponse))")
            if self.parseGetSessionUserInfo(parsingResponse){
                success?()
            }
        } failureInform: {
            API_LOADER.dismiss(animated: false)
        }
    }
    
    func parseGetSessionUserInfo(_ response: [String: JSON]?) -> Bool {
        
        guard let userJSONinfo = response?["payload"] else { return false }
        
        func storeNewUser(strongUserInfo: AppUser) {
            strongUserInfo.assignEnterpriseId(sessionResponse: userJSONinfo)
            UserManager.storeCertifUser(strongUserInfo)
            APP_USER = strongUserInfo // assign user to global variable.
            let defaults = UserDefaults(suiteName: "group.com.ss.doo")
            defaults?.set(APP_USER?.userId, forKey: "UserIdForAllTargets")
            defaults?.synchronize()
            if doWaitForAnimation {
                self.isProfileInfoAPICompleted = true // make it true now.
            }else{
                self.redirectToAddEnterpriseIfNotAvailableOrRedirectToHome()
            }
        }
        
        //while auto login, if there is user already available.
        if let _ = APP_USER {
            APP_USER?.assignEnterpriseId(sessionResponse: userJSONinfo) // If switching to session config API, please change internal code of this function. Commented code kept here. 
            UserManager.saveUser()
            if doWaitForAnimation {
                self.isProfileInfoAPICompleted = true // make it true now.
            }else{
                self.redirectToAddEnterpriseIfNotAvailableOrRedirectToHome()
            }
            return true
        }else if let strongUserInfo = self.userInfo {
            storeNewUser(strongUserInfo: strongUserInfo)
            return true
        }else if let accessToken = self.accessToken{
            // SignUp......
            self.userInfo = AppUser.init(loginResponse: userJSONinfo, authToken: accessToken) // pass auto token to splash model
            storeNewUser(strongUserInfo: self.userInfo!)
            return true
        }else{
            return false
        }
    }
    
    func redirectToAddEnterpriseIfNotAvailableOrRedirectToHome() {
        if let user = APP_USER{
            if user.userSelectedEnterpriseID != nil && user.userSelectedEnterpriseID != 0 {
                // If enterprise available
                // Home
                SceneDelegate.getWindow?.rootViewController = UIStoryboard.dooTabbar.instantiateInitialViewController()
            }else{
                // If enterprise not available
                // Add Enterprise
                SceneDelegate.getWindow?.rootViewController = UIStoryboard.dooTabbar.addEnterpriseWhenNotAvailable
            }
        }else{
            // Logout
            UserManager.logoutMethod() // if still user not available.
        }
    }
}

// MARK:
extension SplashViewModel {
    
    func callFetchProfileInfo(success: (()->())? = nil) {
        
        // API_LOADER.show(animated: false)
        API_SERVICES.callAPI(path: .getUserProfile, method: .get) { (parsingResponse) in
            print("Profile response: \(String(describing: parsingResponse))")
            // API_LOADER.dismiss(animated: false)
            // we are just figuring out
            if self.parseGetSessionUserInfo(parsingResponse){
                success?()
            }
        } failure: { failureMessage in
            UserManager.logoutMethod()
        } internetFailure: {
            UserManager.logoutMethod()
        } failureInform: {
            API_LOADER.dismiss(animated: false)
        }
    }
}
