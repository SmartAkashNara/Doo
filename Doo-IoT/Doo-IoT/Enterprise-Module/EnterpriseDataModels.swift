//
//  EnterpriseDataModels.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 11/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

enum UserRole: Int {
    case applicationUser = 1
    case owner = 2
    case admin = 3
    case user = 4
    
    func getTitle() -> String {
        switch self {
        case .applicationUser:
            return "Application User"
        case .owner:
            return "Owner"
        case .admin:
            return "Admin"
        case .user:
            return "User"
        }
    }
}

protocol DayCategorizable {
    var identifierDate: Date { get }
}

struct EnterpriseGateway {
    var status: Bool = false
    var noOfActiveDevices = 0
    var totalDevices = 0
    var macAddress = ""
}

class EnterpriseModel: DayCategorizable, Equatable {
        
    var id: Int = 0
    var name: String = ""
    var enterpriseTypeId: String = ""
    var enterpriseTypeName: String = ""
    var countryId: String = ""
    var countryName: String = ""
    var stateId: String = ""
    var stateName: String = ""
    var cityId: String = ""
    var cityName: String = ""
    var location: String = ""
    var groups = [EnterpriseGroup]()
    var date: Int = 0
    var identifierDate: Date = Date()
    var lat: Double = 0
    var long: Double = 0
    var active = false
    var privateAccess = false
    var enterpriseGateway: EnterpriseGateway? = nil
    
    var userRole: UserRole = .applicationUser // be default all users are appliacation user.

    init() {
    }

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    init(id: Int, name: String, countryName: String, stateName: String, cityName: String, date: Int) {
        self.id = id
        self.name = name
        self.countryName = countryName
        self.stateName = stateName
        self.cityName = cityName
        self.date = date
    }

    init(dict: JSON) {
        parseEnterprise(dict: dict)
    }
    
    func parseEnterprise(dict: JSON) {
        
        id = dict["id"].intValue
        name = dict["name"].stringValue
        let enterpriseTypeDTO = dict["enterpriseTypeDTO"].dictionaryValue
        enterpriseTypeId = enterpriseTypeDTO["id"]?.stringValue ?? ""
        enterpriseTypeName = enterpriseTypeDTO["name"]?.stringValue ?? ""
        countryId = dict["countryId"].stringValue
        countryName = dict["countryName"].stringValue
        stateId = dict["stateId"].stringValue
        stateName = dict["stateName"].stringValue
        cityId = dict["cityId"].stringValue
        cityName = dict["cityName"].stringValue
        location = dict["location"].stringValue
        lat = dict["latitude"].doubleValue
        long = dict["longitude"].doubleValue
        active = dict["active"].boolValue
        privateAccess = dict["privateAccess"].boolValue
        date = dict["createdAt"].intValue
        userRole = UserRole.init(rawValue: dict["roleId"].intValue) ?? .applicationUser
        
        if let arrayGroupList = dict["groupList"].array{
            groups.removeAll()
            arrayGroupList.forEach { (group) in
                groups.append(EnterpriseGroup(dict: group, flow: .addEnterprise))
            }
        }
    }
    
    static func == (lhs: EnterpriseModel, rhs: EnterpriseModel) -> Bool {
        return (lhs.id == rhs.id)
    }
}

class DooUser {
    var id = 0
    var userId = 0
    var avatarId = 0
    var firstName = ""
    var lastName = ""
    var fullname = ""
    var mobile = ""
    var email = ""
    var contact = "" // Email and mobile both
    var image = ""
    var roleId = ""
    var roleName = ""
    var invitationStatus = 0
    var invitationStatusName = ""
    var enterpriseId = 0
    var enable = false

    var privilegesTree: InfinityTree? = nil
    var selected: Bool = false

    var getMobileOrEmail: String {
        return mobile.isEmpty ? email : mobile
    }
    var getEmailOrMobile: String {
        return email.isEmpty ? mobile : email
    }
    var getEnumInvitationStatus: EnterpriseUserTVCell.EnumInvitationStatus? {
        return EnterpriseUserTVCell.EnumInvitationStatus(rawValue: invitationStatus)
    }
    
    init(id: Int, firstName: String, lastName: String, mobile: String, email: String, image: String, invitationStatus: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.mobile = mobile
        self.email = email
        self.image = image
        self.invitationStatus = invitationStatus
    }
    
    init(dict: JSON) {
        id = dict["id"].intValue
        userId = dict["userId"].intValue
        avatarId = dict["avatarId"].intValue
        email = dict["email"].stringValue
        mobile = dict["contactNumber"].stringValue
        contact = dict["contact"].stringValue // Email or Mobile (Generic)
        fullname = dict["name"].stringValue

        roleId = dict["roleId"].stringValue
        roleName = dict["roleName"].stringValue
        invitationStatus = dict["invitationStatus"].intValue
        invitationStatusName = dict["invitationStatusName"].stringValue

        enterpriseId = dict["enterpriseId"].intValue
        enable = dict["enable"].boolValue
        image = dict["image"].stringValue
    }
    func updateUserInfo(withUserDetail userDetail: JSON) {
        image = userDetail["originalImage"].stringValue
    }
}

class EnterpriseGroup {
    
    var id: Int = 0
    var enterpriseTypeId: Int = 0
    var groupMasterId: Int = -1
    var name: String = ""
    var detail: String = ""
    var image: String = ""
    var enterpriseTypeName: String = ""
    var imageUploaded = false
    var enable = false

    var checked = false
    var groupOfAddTime = false
    
    var enumGroupType: GroupDataModel.EnumGroupType{
        if groupMasterId == -1 || groupMasterId == 0{
            return .simpleGroup
        }else{
            return .masterGroup
        }
    }

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    enum EnumGroupFlow { case groupListApi, addEnterprise }
    
    init(dict: JSON, flow: EnumGroupFlow) {
        
        id = dict["id"].intValue
        enterpriseTypeId = dict["enterpriseTypeId"].intValue
        groupMasterId = dict["groupMasterId"].intValue
        
        switch flow {
        case .groupListApi:
            groupMasterId = id
        case .addEnterprise:
            break
        }
        name = dict["name"].stringValue
        detail = dict["description"].stringValue
        image = dict["image"].stringValue
        enterpriseTypeName = dict["enterpriseTypeName"].stringValue

        imageUploaded = dict["imageUploaded"].boolValue
        enable = dict["enable"].boolValue
    }
    
    init(fromAddGroup data: GroupDataModel) {
        groupMasterId = data.id
        name = data.name
    }
}


