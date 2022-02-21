//
//  Routing.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 22/12/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

enum Routing {
    
    // Signup & Signin APIs ----------------------------------------------------------
    case countrySelection
    case registerUsingEmail
    case registerUsingMobileNo
    case normalLogin([String: Any])
    case forgotPasswordInitial([String: Any])
    case resendRegisterWithEmailOrMobileOTP     // resend otp
    case resendForgotPassword                   // resend OTP
    case loginWithSMS                           // Also used for resend OTP
    case resendOTPUpdateProfile([String: Any])  // Resend OTP
    case verifyOTPForgotPassword([String: Any]) // verify forgot password OTP
    case verifySignupAuthenticationOTP([String: Any]) // Verify signup contact authentication OTP
    case loginWithSMSOTP([String: Any])         // Login with SMS OTP verification
    case getUserSessionInfo
    case verifyOTPUpdateProfile(String)
    case setPasswordWhileSignup                  // Signup password registration after OTP verification
    case setForgotPasswordReset
    case changePassword
    
    case getEnterprises
    case switchEnterprise([String: Any])
    case getTypesOfEnterprises
    case addEnterprise
    case updateEnterprise(String)
    case getGroups(Bool, String)
    case createGroup
    case updateGroupName(Int)
    
    case getEnterpriseWiseGroupsFilter(Int)
    case getUsersBelongsToEnterprise([String: Any])
    case enableDisableEnterpriseUser([String: Any])
    case reinviteEnterpriseUser([String: Any])
    case getOtherUserProfileData([String: Any])
    case deleteEnterpriseUser([String: Any])
    case changeRoleOfEnterpriseUser([String: Any])
    
    case getPrivillegsDevicesByUserIdToEnterprise([String: Any])
    case updateDeviceInGroup(Int)
    case getUserPrivillegsDevicesToEnterprise([String: Any])
    case getSelectedUsersPrivillegsOfDevices(String)

    case getAllDevicesForGroup
    case assignDeviceToUserEnterprise
    
    case addDevice
    case updateDevice([String: Any])
    case getGatewayList
        
    // smart rule
    case bindingRuleList([String: Any])
    case scheduleList([String: Any])
    case sceneList([String: Any])
    case bindingRuleEnableDisable([String: Any])
    case scheduleEnableDisable([String: Any])
    case excuteScene([String: Any])
    case deleteBindingRule([String: Any])
    case deleteScene([String: Any])
    case deleteSchedule([String: Any])
    case deleteAllSchedules
    case addBindingRule
    case addScheduler
    case addScene
    case updateBindingRule
    case updateSchedule
    case updateScene
    case sceneEnableDisable([String: Any])
    case sceneFavouriteUnFavourite([String: Any])
    case sceneFavouriteList
    
    case getDeviceListByType(String?)
    case getDeviceTypeList
    case getDeviceDetailFromDeviceId(String?)
    case applianceToggleFavourite([String: Any])
    case applianceToggleEnable([String: Any])
    case deleteDevice
    case getApplianceTypeList
    case updateAppliance
    
    case getFavourites
    case logout
    case getUserProfile
    case getDefaultAvatars
    case updateProfilePicture
    case updateUserProfile
    
    case getUserRoles
    case inviteEnterpriseUsers
    case getAllEnterpriseUsers(String)
    case getUsersPrivillegsBelongsToEnterprise
    case enterpriseReceivedInvitations
    case acceptRejectReceivedInvitaiton([String:Any])
    
    case getDeviceDetailFromSerialNumber(String)
    case getDefaultSceneList
    case applienceONOFF
    
    
    // group
    case getAllGroups
    case getGroupDetail(Int)
    case groupEnableDisable(Int,Bool)
    case removeGroup(Int)
    case groupAllDeviceApplienceONOFF(Int, Int)
    case getGatewayPresence(Int)
    case getAllAppliancesFoSiri
    
    // alexa
    case getAuth2Code
    case enableAlexaSkill
    case checkAlexaSkillEnable
    
    var getPath: String {
        switch self {
        case .countrySelection:
            return "doo/public/country/list"
        case .registerUsingEmail:
            return "doo/public/register/email"
        case .registerUsingMobileNo:
            return "doo/public/register/mobile"
        case .normalLogin(let param):
            guard let emailOrMobile = param["emailOrMobile"] as? String else { return "" }
            switch emailOrMobile {
            case "email":
                return "doo/public/login/email"
            case "mobile":
                return "doo/public/login/mobile"
            default:
                return ""
            }
        case .forgotPasswordInitial(let param):
            guard let emailOrMobile = param["emailOrMobile"] as? String else { return "" }
            switch emailOrMobile {
            case "email":
                return "doo/public/forgot/password/email"
            case "mobile":
                return "doo/public/forgot/password/mobile"
            default:
                return ""
            }
        case .resendRegisterWithEmailOrMobileOTP:
            return "doo/public/register/resend/otp"
        case .resendForgotPassword:
            return "doo/public/forgot/resend/otp"
        case .loginWithSMS:
            return "doo/public/login/mobile/otp"
        case .resendOTPUpdateProfile(let param):
            guard let otpUuid = param["otpUuid"] as? String else { return "" }
            return "doo/protected/user/resend/\(otpUuid)"
        case .verifyOTPForgotPassword(let param):
            guard let otp = param["otp"] as? String else { return "" }
            return "doo/public/forgot/verify/otp/\(otp)"
        case .verifySignupAuthenticationOTP(let param):
            guard let otp = param["otp"] as? String else { return "" }
            return "doo/public/register/verify/\(otp)"
        case .loginWithSMSOTP(let param):
            guard let otp = param["otp"] as? String else { return "" }
            return "doo/public/login/mobile/otp/\(otp)"
        case .getUserSessionInfo:
            return "doo/protected/user/session"
        case .verifyOTPUpdateProfile(let otpUuid):
//            guard let otp = param["otp"] as? String else { return "" }
            return "doo/protected/user/verify/\(otpUuid)"
        case .setPasswordWhileSignup:
            return "doo/public/register"
        case .setForgotPasswordReset:
            return "doo/public/reset/forgot/password"
        case .changePassword:
            return "doo/protected/password"
        case .getEnterprises:
            return "doo/protected/enterprise/filter"
        case .switchEnterprise(let param):
            guard let enterpriseId = param["enterpriseId"] as? Int else { return "" }
            return "doo/protected/enterprise/\(enterpriseId)/switch"
        case .getTypesOfEnterprises:
            return "doo/protected/enterprise/type/filter"
        case .addEnterprise:
            return "doo/protected/enterprise"
        case .updateEnterprise(let enterpriseId):
            return "doo/enterprise/\(enterpriseId)"
        case .getEnterpriseWiseGroupsFilter(let enterpriseId):
            return "doo/group/enterprise/filter/\(enterpriseId)"
        case .getUsersBelongsToEnterprise(let param):
            guard let enterpriseId = param["enterpriseId"] as? String else { return "" }
            if let searchingValue = param["searchingValue"] as? String, !searchingValue.isEmpty {
                return "doo/enterprise/user/\(enterpriseId)/\(searchingValue)"
            }else{
                return "doo/enterprise/user/\(enterpriseId)"
            }
        case .enableDisableEnterpriseUser(let param):
            guard let id = param["id"] as? Int,
                  let flag = param["flag"] as? Bool,
                  let enterpriseId = param["enterpriseId"] as? Int else { return "" }
            return "doo/enterprise/user/toggle/\(id)/\(flag)/\(enterpriseId)"
        case .reinviteEnterpriseUser(let param):
            guard let id = param["id"] as? Int else { return "" }
            return "doo/enterprise/user/reinvite/\(id)"
        case .getOtherUserProfileData(let param):
            guard let id = param["id"] as? String else { return "" }
            return "doo/protected/user/profile/\(id)"
        case .deleteEnterpriseUser(let param):
            guard let userId = param["userId"] as? String, let enterpriseId = param["enterpriseId"] else { return "" }
            return "doo/enterprise/user/\(userId)/\(enterpriseId)"
            
        case .getPrivillegsDevicesByUserIdToEnterprise(let param):
            guard let userId = param["userId"] as? Int else { return "" }
            return "doo/user/appliance/\(userId)"
        case .getUserPrivillegsDevicesToEnterprise(let param):
            if let userId = param["userId"] as? String {
                if userId != "" {
                    return "doo/user/appliance/\(userId)"
                }
                return "doo/user/appliance/"
            }
            return "doo/user/appliance/list"
        case .getSelectedUsersPrivillegsOfDevices(let userId):
            return "doo/user/appliance/list?userId=\(userId)"
        case .changeRoleOfEnterpriseUser(let param):
            guard let userId = param["userId"] as? String,
                  let roleId = param["roleId"] as? String,
                  let enterpriseId = param["enterpriseId"] as? String else { return "" }
            return "doo/enterprise/user/change/role/\(userId)/\(roleId)/\(enterpriseId)"
        case .updateDeviceInGroup(let groupId):
            return "doo/group/update/appliance/\(groupId)"
        case .getAllDevicesForGroup:
            return "doo/device/enterprise"
        case .assignDeviceToUserEnterprise:
            return "doo/user/appliance"
            
        case .addDevice:
            return "doocore/v1/device/register"//"doo/device"
        case .updateDevice(let param):
            guard let deviceId = param["deviceId"] as? String,
                  let name = param["name"] as? String else { return "" }
            return "doo/device/\(deviceId)/\(name)"
        case .getGatewayList:
            return "doo/device/gateway"
            
            // smart rule
        case .bindingRuleList(let param):
            guard let page = param["page"] as? Int,
                  let limit = param["limit"] as? Int else { return "" }
            return "doocore/v1/rule/binding/list?limit=\(limit)&page=\(page)"
        case .scheduleList(let param):
            guard let page = param["page"] as? Int,
                  let limit = param["limit"] as? Int else { return "" }
            return "doocore/v1/rule/scheduler/list?limit=\(limit)&page=\(page)"
        case .sceneList(let param):
            guard let page = param["page"] as? Int,
                  let limit = param["limit"] as? Int else { return "" }
            return "doocore/v1/rule/scene/list?limit=\(limit)&page=\(page)"
        case .bindingRuleEnableDisable(let param):
            guard let id = param["id"] as? Int,
                  let status = param["status"] as? Int else { return "" }
            return "doocore/v1/rule/binding/enable/\(id)/\(status)"
        case .scheduleEnableDisable(let param):
            guard let id = param["id"] as? Int,
                  let status = param["status"] as? Int else { return "" }
            return "doocore/v1/rule/scheduler/enable/\(id)/\(status)"
        case .excuteScene(let param):
            guard let id = param["id"] as? Int else { return "" }
            return "doocore/v1/rule/scene/execute/\(id)"
        case .deleteBindingRule(let param):
            guard let id = param["id"] as? Int else { return "" }
            return "doocore/v1/rule/binding/delete/\(id)"
        case .deleteScene(let param):
            guard let id = param["id"] as? Int else { return "" }
            return "doocore/v1/rule/scene/delete/\(id)"
        case .deleteSchedule(let param):
            guard let id = param["id"] as? Int else { return "" }
            return "doocore/v1/rule/scheduler/delete/\(id)"
        case .deleteAllSchedules:
            return "doocore/v1/rule/scheduler/delete/all"
        case .addBindingRule:
            return "doocore/v1/rule/binding/create"
        case .addScheduler:
            return "doocore/v1/rule/scheduler/create"
        case .addScene:
            return "doocore/v1/rule/scene/create"
        case .updateBindingRule:
            return "doocore/v1/rule/binding/update"
        case .updateSchedule:
            return "doocore/v1/rule/scheduler/update"
        case .updateScene:
            return "doocore/v1/rule/scene/update"
        case .sceneEnableDisable(let param):
            guard let id = param["id"] as? Int,
                  let status = param["status"] as? Int else { return "" }
            return "doocore/v1/rule/scene/enable/\(id)/\(status)"
        case .sceneFavouriteUnFavourite(let param):
            guard let id = param["id"] as? Int,
                  let status = param["status"] as? Int else { return "" }
            return "doocore/v1/rule/scene/toggle/favourite/\(id)/\(status)"
        case .sceneFavouriteList:
            return "doocore/v1/rule/scene/favourite/list"            
        case .getDeviceListByType(let searchText):
            if let userParam = searchText{
                return "doo/device/gateway/filter/\(userParam)"
            } else {
                return "doo/device/gateway/filter"
            }
        case .getDeviceTypeList:
            return "doo/device/type"
        case .getDeviceDetailFromDeviceId(let deviceId):
            guard let id = deviceId, id != "0" else {
                return "doo/device"
            }
            return "doo/device/\(id)"
        case .applianceToggleFavourite(let param):
            guard let id = param["id"] as? String,
                  let flag = param["flag"] as? Bool else { return "" }
            return "doo/device/toggle/favourite/\(id)/\(flag)"
        case .applianceToggleEnable(let param):
            guard let applianceId = param["applianceId"] as? Int,
                  let flag = param["flag"] as? Int else { return "" }
            return "doocore/v1/appliance/access/toggle/\(applianceId)/\(flag)"//"doo/device/appliance/toggle/enable/\(applianceId)/\(flag)"
        case .deleteDevice:
            return "doocore/v1/device/unregister"
            /*
            if isGateway{
                return "doo/device/gateway/delete/\(deviceId)"
            }else{
                return "doo/device/delete/\(deviceId)"
            }*/
        case .getApplianceTypeList:
            return "doo/appliance/type"
        case .updateAppliance:
            return "doo/device/appliance/update"

        case .getFavourites:
            return "doo/appliance/favourite"
        case .logout:
            return "identity/logout"
        case .getUserProfile:
            return "doo/protected/user/profile"
        case .getDefaultAvatars:
            return "doo/protected/user/profile/avatar"
        case .updateProfilePicture:
            return "doo/protected/user/profile/picture/update"
        case .updateUserProfile:
            return "doo/protected/user/profile/update"
            
        case .getUserRoles:
            return "doo/user/role"
        case .inviteEnterpriseUsers:
            return "doo/enterprise/user/invite"
        case .getAllEnterpriseUsers(let searchText):
            if !searchText.isEmpty {
                return "doo/enterprise/all/user/\(searchText)"
            } else {
                return "doo/enterprise/all/user"
            }
        case .getUsersPrivillegsBelongsToEnterprise:
            return "private/privilege"
        case .enterpriseReceivedInvitations:
            return "doo/protected/enterprise/user/invitation"
        case .acceptRejectReceivedInvitaiton(let param):
            guard let invitationId = param["invitationId"] as? String else { return "" }
            guard let flag = param["flag"] as? String else { return "" }
            return "doo/protected/enterprise/user/invitation/\(invitationId)/\(flag)"
        case .getDeviceDetailFromSerialNumber(let serialNumber):
            guard !serialNumber.isEmpty else { return "" }
            return "doo/device/detail/\(serialNumber)"
        case .getDefaultSceneList:
            return "doocore/v1/rule/scene/defaults"
        case .applienceONOFF:
            return "doocore/v1/appliance/action"
            
            
        // group
        case .getAllGroups:
            return "doo/group"
        case .getGroupDetail(let groupId):
            return "doo/group/\(groupId)"
        case .groupEnableDisable(let groupId, let status):
            return "doo/group/\(groupId)/\(status)"
        case .createGroup:
            return "doo/group"
        case .updateGroupName(let groupId):
            return "doo/group/update/name/\(groupId)"
        case .getGroups(let isUpdate, let enterpriseID):
            if isUpdate{
                return "doo/protected/group/filter?enterpriseId=\(enterpriseID)&update=true"
            }else{
                return "doo/protected/group/filter?update=false"
            }
        case .removeGroup(let groupId):
            return "doo/group/\(groupId)"
        case .groupAllDeviceApplienceONOFF(let groupId, let action):
            return "doocore/v1/group/\(groupId)/action/\(action)"
        case .getGatewayPresence(let deviceID):
            return "doocore/v1/presence/status/\(deviceID)"
        case .getAllAppliancesFoSiri:
            return "doo/group/appliance/all"
            
            
            // alexa
        case .getAuth2Code:
            return "doo/alexa/urls"
        case .enableAlexaSkill:
            return "doo/alexa/skill/enablement"
        case .checkAlexaSkillEnable:
            return "doo/protected/user/skill/enable"

        }
    }
}
