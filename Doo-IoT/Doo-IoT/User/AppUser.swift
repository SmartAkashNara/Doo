//
//  User.swift
//  BaseProject
//
//  Created by MAC240 on 04/06/18.
//  Copyright © 2018 MAC240. All rights reserved.
//

import Foundation

class AppUser : NSObject, NSCoding {
        
    var accessToken: String?
    var refreshToken: String?
    
    var userId              :Int = 0
    var profile_name        :String = ""
    var email               :String = ""
    var emailToken          :String = ""
    var profile_picture     :String = ""
    
    var privilegesIDsList   : [Int] = []
    var rolesIDsList        : [Int] = []
    
    var firstName: String = ""
    var lastName: String = ""
    var fullName: String { return [firstName, lastName].removeEmptiesAndJoinWith(" ") }

    var dialCode = ""
    var countryCode: Int = 0
    var countryName: String = ""
    var mobileNumber: String = ""
    var mobileToken: String = ""
    var originalImage: String = ""
    var thumbnailImage: String = ""
    var role: String = ""
    var profilePic: Bool = false
    var timeout: Int = 0

    var userSelectedEnterpriseID : Int? = nil
    // Below code will be called from 5 places.
    // 1. from menuViewModel = when you have above enterpirse id but don't have selected enterprise model, will assign it when you will fetch all enterprises at menu view controller
    // 2. from menu view controller, switching enterprise by Swipe up and Swipe down.
    // 3. from Enterprise top menu view controller, switching enterprise from top layout
    // 4. from adding new enterprise
    // 5. receiving new enterprise invitation.
    var selectedEnterprise  : EnterpriseModel? = nil {
        didSet {
            self.userSelectedEnterpriseID = selectedEnterprise?.id
        }
    }
    
    
    /// This method is used to show card alert on application level
    /// :param: Dictionary is passed as `parameter` with all user data
    /// :returns: returns `User` object
    required init(parameter: JSON) {
        if parameter.isEmpty != true {
            self.userId = parameter["userId"].intValue
            self.email = parameter["email"].stringValue
            
            let enterpriseIds = parameter["enterpriseIds"].arrayValue.map({$0.intValue})
            if enterpriseIds.count != 0 {
                self.userSelectedEnterpriseID = enterpriseIds[0]
            }
        }
    }
    
    required init(loginResponse: JSON, authToken: String) {
        super.init()
        if loginResponse.isEmpty != true {
            self.accessToken = authToken
            self.update(profileResponse: loginResponse)
        }
    }
    
    func update(profileResponse: JSON) {
        self.userId = profileResponse["userId"].intValue
        self.firstName = profileResponse["firstName"].stringValue
        self.lastName = profileResponse["lastName"].stringValue
        self.email = profileResponse["email"].stringValue
        self.emailToken = profileResponse["emailToken"].stringValue
        self.dialCode = profileResponse["dialCode"].stringValue
        self.countryCode = profileResponse["countryCode"].intValue
        self.countryName = profileResponse["country"].stringValue
        self.mobileNumber = profileResponse["mobileNumber"].stringValue
        self.mobileToken = profileResponse["mobileToken"].stringValue
        self.originalImage = profileResponse["originalImage"].stringValue
        self.thumbnailImage = profileResponse["thumbnailImage"].stringValue
        self.profilePic = profileResponse["profilePic"].boolValue
        self.timeout = profileResponse["timeout"].intValue
        self.role = profileResponse["role"].stringValue
    }
    
    func assignEnterpriseId(sessionResponse: JSON) {

        debugPrint("Selected enterprise: \(sessionResponse["currentEnterpriseId"].intValue)")
        var selectedEnterpriseID = sessionResponse["currentEnterpriseId"].intValue
        
        // if selected enterprise id is not available in the list you receives, choose the first one you have...
        let enterpriseIds = sessionResponse["enterpriseIds"].arrayValue.map({$0.intValue})
        if enterpriseIds.count != 0 && !enterpriseIds.contains(selectedEnterpriseID) {
            selectedEnterpriseID = enterpriseIds.first!
        }
        for enterpriseId in enterpriseIds {
            if enterpriseId == self.userSelectedEnterpriseID {
                selectedEnterpriseID = enterpriseId
            }
        }
        self.userSelectedEnterpriseID = selectedEnterpriseID // transfer final
    }

    
    required init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    required init(coder decoder: NSCoder) {
        self.userId = decoder.decodeInteger(forKey: "userId")
        if let profile_name = decoder.decodeObject(forKey: "profile_name") as? String {
            self.profile_name = profile_name
        }
        if let email = decoder.decodeObject(forKey: "email") as? String {
            self.email = email
        }
        if let profile_picture = decoder.decodeObject(forKey: "thumbnailImage") as? String {
            self.thumbnailImage = profile_picture
        }
        if let profile_picture = decoder.decodeObject(forKey: "originalImage") as? String {
            self.originalImage = profile_picture
        }
        if let firstName = decoder.decodeObject(forKey: "firstName") as? String {
            self.firstName = firstName
        }
        if let lastName = decoder.decodeObject(forKey: "lastName") as? String {
            self.lastName = lastName
        }
        if let accessToken = decoder.decodeObject(forKey: "accessToken") as? String {
            self.accessToken = accessToken
        }
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encode(self.userId, forKey: "userId")
        encoder.encode(self.profile_name, forKey: "profile_name")
        encoder.encode(self.email, forKey: "email")
        encoder.encode(self.thumbnailImage, forKey: "thumbnailImage")
        encoder.encode(self.firstName, forKey: "firstName")
        encoder.encode(self.lastName, forKey: "lastName")
        encoder.encode(self.accessToken, forKey: "accessToken")
    }
}

