//
//  LoginViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 02/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class LoginViewModel {
    
    var splashModel: SplashViewModel = SplashViewModel()
    
    func callLoginAPI(_ param: [String: Any], routing: Routing) {
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: routing, method: .post) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            debugPrint("response: \(parsingResponse)")
            guard let payload = parsingResponse?["payload"]?.dictionaryValue,
                let authResponse = payload["authResponse"]?.dictionaryValue,
                let accessToken = authResponse["accessToken"]?.stringValue else { return }
            
            // Profile information
            if let profileInfo = payload["profile"] {
                NetworkingManager.shared.setAuthorization(accessToken)
                self.splashModel.doWaitForAnimation = false // splash is for animation too. 
                self.splashModel.userInfo = AppUser.init(loginResponse: profileInfo, authToken: accessToken) // pass auto token to splash model
                let defaults = UserDefaults(suiteName: "group.com.ss.doo")
                defaults?.set(accessToken, forKey: "AccessTokenForAllTargets")
                defaults?.set(APP_USER?.userId, forKey: "UserIdForAllTargets")
                defaults?.synchronize()
                self.splashModel.callFetchProfileInfo()
            }
        }
    }
}
