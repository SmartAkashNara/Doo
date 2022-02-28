//
//  UserManager.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 23/12/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import UIKit

var APP_USER: AppUser? = nil

// frpm user instance itself, user can be saved.
extension AppUser {
    func saveUser() {
        UserManager.saveUser()
    }
}

struct UserManager {
    
    static let CertifUserKey = "CertifUser"
    
    static func storeCertifUser(_ dooUser: AppUser?) {
        
        guard let strongUser = dooUser else {return}
                
        NetworkingManager.shared.setAuthorization(strongUser.accessToken ?? "") // NETWORKING... whenver user gets updated. just set new accesstoken to networking...
        
        UserManager.archieveAndStoreCertifUser(strongUser)
    }
    
    static func saveUser() {
        if let strongUser = APP_USER {
            self.archieveAndStoreCertifUser(strongUser)
        }
    }
    
    // Actual store
    private static func archieveAndStoreCertifUser(_ strongUser: AppUser) {
        // https://stackoverflow.com/questions/37028194/cannot-decode-object-of-class-employee-for-key-ns-object-0-the-class-may-be-d
        // the class may be defined in source code or a library that is not linked
        NSKeyedArchiver.setClassName("CertifUser", for: AppUser.self)
        
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: strongUser, requiringSecureCoding: false) {
                UserDefaults.standard.set(encodedData, forKey: CertifUserKey)
                UserDefaults.standard.synchronize()
        }
    }
    
    static func getCertifUser() -> AppUser? {
        
        NSKeyedUnarchiver.setClass(AppUser.self, forClassName: "CertifUser")
        guard let storedObject: Data = UserDefaults.standard.object(forKey: CertifUserKey) as? Data else {
            return nil
        }
        do {
            
            if let storedUser: AppUser = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storedObject) as? AppUser{
                NetworkingManager.shared.setAuthorization(storedUser.accessToken ?? "") // NETWORKING...
                return storedUser
            }
            return nil
        } catch{
           debugPrint(error)
            return nil
        }
    }
}

extension UserManager {
    static func logoutMethod() {
        if let _ = (SceneDelegate.getWindow?.rootViewController as? UINavigationController)?.viewControllers.first as? LoginViewController {
            // If user already in SignIn and verification failed via wrong password
        }else{
            // When user inside app or other process like, location add or learning journey.
            clear()
            
            // Move to signup flow...
            SceneDelegate.getWindow?.rootViewController = UIStoryboard.onboarding.instantiateInitialViewController()
        }
    }
    
    static func clear() {
        TABBAR_INSTANCE = nil // remove tabbar instance set globally.
        UserDefaults.standard.removeObject(forKey: CertifUserKey)
        UserDefaults.standard.synchronize()
        APP_USER = nil
        API_SERVICES.removeAuthorizationAndVarification() // Networking...
        IS_USER_INSIDE_APP = false // User is not inside app any more.
        
        let defaults = UserDefaults(suiteName: "group.com.ss.doo")
        defaults?.removeObject(forKey: "AccessTokenForAllTargets")
        defaults?.removeObject(forKey: "UserIdForAllTargets")
        defaults?.synchronize()
        MQTTSwift.shared.unsubscribeMQTT()
    }
}
