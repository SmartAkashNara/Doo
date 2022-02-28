//
//  APIRouter.swift
//  BaseProject
//
//  Created by MAC240 on 04/06/18.
//  Copyright © 2018 MAC240. All rights reserved.
//

import Foundation
import Alamofire


protocol Routable {
    var path       : String { get }
    var method     : HTTPMethod { get }
    var parameters : Parameters? { get }
}


enum APIRouter: Routable {
    // Generic
    case countrySelection(Parameters)
    
    // Signup
    case registerUsingEmail(Parameters)
    case registerUsingMobileNo(Parameters)
    case resendOTP(Parameters)
    case verifyOTP(Parameters)
    case registerUsingPassword(Parameters)
    
    // Login
    case login(Parameters)
    case loginWithSMS(Parameters)
    case loginWithSMSOTP(Parameters)
    
    // Forgot password
    case forgotPassword(Parameters)
    case resendForgotPassword(Parameters)
    case verifyOTPForgotPassword(Parameters)
    case resetPasswordForgotPassword(Parameters)
    
    // Change password
    case changePassword(Parameters)
    
    // Enterprises
    case getTypesOfEnterprises(Parameters)
    case addEnterprise(Parameters)
    case updateEnterprise(Parameters)
    case getEnterprises(Parameters)
    case getEnterpriseGroups(Parameters)
    case getAllEnterpriseUsers(Parameters)
    case getUsersBelongsToEnterprise(Parameters)
    case inviteEnterpriseUsers(Parameters)
    case getUsersPrivillegsBelongsToEnterprise(Parameters)
    case getUserPrivillegsDevicesToEnterprise(Parameters)
    case assignDeviceToUserEnterprise(Parameters)
    case getPrivillegsDevicesByUserIdToEnterprise(Parameters)
    
    case getUserSessionInfo(Parameters)
    case getUserRoles(Parameters)
    
    case switchEnterprise(Parameters)
    case enterpriseReceivedInvitations(Parameters)
    case acceptRejectReceivedInvitaiton(Parameters)
    case enableDisableEnterpriseUser(Parameters)
    case reinviteEnterpriseUser(Parameters)
    case changeRoleOfEnterpriseUser(Parameters)
    
    // Profile
    case getProfileData(Parameters)
    case getDefaultAvatars(Parameters)
    case updateProfileData(Parameters)
    case updateProfilePicture(Parameters)
    case deleteProfilePicture(Parameters)
    case resendOTPUpdateProfile(Parameters)
    case verifyOTPUpdateProfile(Parameters)
    case getOtherUserProfileData(Parameters)
    case deleteEnterpriseUser(Parameters)
    
    // Device flow
    case getDeviceTypeList(Parameters)
    case getDeviceListByType(Parameters)
    case getDeviceDetailFromDeviceId(Parameters)
    case getDeviceDetailFromSerialNumber(Parameters)
    case getGatewayList(Parameters)
    case addDevice(Parameters)
    case updateDevice(Parameters)
    case deleteDevice(Parameters)
    case applianceToggleFavourite(Parameters)
    case applianceToggleEnable(Parameters)
    case getApplianceTypeList(Parameters)
    case updateAppliance(Parameters)
    case deviceApplienceONOFF(Parameters)
    
    // Group flow
    case getAllGroups(Parameters)
    case getGroupDetail(Parameters)
    case updateGroupName(Parameters)
    case groupEnableDisable(Parameters)
    case removeGroup(Parameters)
    case createGroup(Parameters)
    case getAllDevicesForGroup(Parameters)
    case updateDeviceInGroup(Parameters)
    case groupEnterpriseFilter(Parameters)
    case groupAllDeviceApplienceONOFF(Parameters)
    case logout(Parameters)
    
    
    case scheduleList(Parameters)
    case sceneList(Parameters)
    case bindingRuleList(Parameters)
    case bindingRuleEnableDisable(Parameters)
    case scheduleEnableDisable(Parameters)
    case deleteSchedule(Parameters)
    case updateSchedule(Parameters)
    case deleteBindingRule(Parameters)
    case updateBindingRule(Parameters)
    case deleteScene(Parameters)
    case updateScene(Parameters)
    case addBindingRule(Parameters)
    case addScheduler(Parameters)
    case addScene(Parameters)
    case getDeafultMasterSceneList(Parameters)
    case excuteScene(Parameters)

    case getFavouriteList(Parameters)

    //    case getAllDeviceListOfEnterprise(Parameters)
    
    
}

extension APIRouter {
    
    var path: String {
        switch self {
        // Generic
        case .countrySelection:
            return Environment.APIBasePath() + "doo/public/country/list"
            
        // Signup
        case .registerUsingEmail:
            return Environment.APIBasePath() + "doo/public/register/email"
        case .registerUsingMobileNo:
            return Environment.APIBasePath() + "doo/public/register/mobile"
        case .resendOTP:
            return Environment.APIBasePath() + "doo/public/register/resend/otp"
        case .verifyOTP(let param):
            if let otpValue = param["OTP"] as? String {
                return Environment.APIBasePath() + "doo/public/register/verify/\(otpValue)"
            }
            return Environment.APIBasePath() + "doo/public/register/verify"
        case .registerUsingPassword:
            return Environment.APIBasePath() + "doo/public/register"
            
        // Login
        case .login(let param):
            guard let emailOrMobile = param["emailOrMobile"] as? String else { return "" }
            switch emailOrMobile {
            case "email":
                return Environment.APIBasePath() + "doo/public/login/email"
            case "mobile":
                return Environment.APIBasePath() + "doo/public/login/mobile"
            default:
                return ""
            }
        case .loginWithSMS:
            return Environment.APIBasePath() + "doo/public/login/mobile/otp"
        case .loginWithSMSOTP(let param):
            if let otpValue = param["OTP"] as? String {
                return Environment.APIBasePath() + "doo/public/login/mobile/otp/\(otpValue)"
            }
            return Environment.APIBasePath() + "doo/public/login/mobile/otp"
            
        // Forgot password
        case .forgotPassword(let param):
            guard let emailOrMobile = param["emailOrMobile"] as? String else { return "" }
            switch emailOrMobile {
            case "email":
                return Environment.APIBasePath() + "doo/public/forgot/password/email"
            case "mobile":
                return Environment.APIBasePath() + "doo/public/forgot/password/mobile"
            default:
                return ""
            }
        case .resendForgotPassword:
            return Environment.APIBasePath() + "doo/public/forgot/resend/otp"
        case .verifyOTPForgotPassword(let param):
            guard let otp = param["otp"] as? String else { return "" }
            return Environment.APIBasePath() + "doo/public/forgot/verify/otp/\(otp)"
        case .resetPasswordForgotPassword:
            return Environment.APIBasePath() + "doo/public/reset/forgot/password"
            
        // Change password
        case .changePassword:
            return Environment.APIBasePath() + "doo/protected/password"
            
        // Enterprises
        case .getTypesOfEnterprises:
            //            return Environment.APIBasePath() + "platform/enterprise/type/filter"
            return Environment.APIBasePath() + "doo/enterprise/type/filter"
        case .addEnterprise:
            return Environment.APIBasePath() + "doo/enterprise"
        case .updateEnterprise(let param):
            guard let enterpriseId = param["enterpriseId"] as? String else { return "" }
            return Environment.APIBasePath() + "doo/enterprise/\(enterpriseId)"
        case .getEnterprises:
            return Environment.APIBasePath() + "doo/enterprise/filter"
        case .getAllEnterpriseUsers(let param):
            if let searchText = param["searchText"] as? String {
                return Environment.APIBasePath() + "doo/enterprise/all/user/\(searchText)"
            } else {
                return Environment.APIBasePath() + "doo/enterprise/all/user"
            }
        case .getUsersBelongsToEnterprise(let param):
            guard let enterpriseId = param["enterpriseId"] as? String else { return "" }
            return Environment.APIBasePath() + "doo/enterprise/user/\(enterpriseId)"
        case .inviteEnterpriseUsers:
            return Environment.APIBasePath() + "doo/enterprise/user/invite"
        case .getEnterpriseGroups(let param):
            if let _ = param["update"] as? Bool{
                return Environment.APIBasePath() + "doo/group/filter?update=true"
            }else{
                return Environment.APIBasePath() + "doo/group/filter?update=false"
            }
            
        case .getUsersPrivillegsBelongsToEnterprise:
            return Environment.APIBasePath() + "private/privilege"
            
        // Get User Info
        case .getUserSessionInfo:
            return Environment.APIBasePath() + "doo/protected/user/session"
        case .getUserRoles:
            return Environment.APIBasePath()+"doo/user/role"
            
        case .switchEnterprise(let param):
            guard let enterpriseId = param["enterpriseId"] as? Int else { return "" }
            return Environment.APIBasePath() + "doo/enterprise/\(enterpriseId)/switch"
            
        case .enterpriseReceivedInvitations:
            return Environment.APIBasePath() + "doo/enterprise/user/invitation"
        case .acceptRejectReceivedInvitaiton(let param):
            guard let invitationId = param["invitationId"] as? String else { return "" }
            guard let flag = param["flag"] as? String else { return "" }
            return Environment.APIBasePath() + "doo/enterprise/user/invitation/\(invitationId)/\(flag)"
            
        case .enableDisableEnterpriseUser(let param):
            guard let id = param["id"] as? Int,
                  let flag = param["flag"] as? Bool,
                  let enterpriseId = param["enterpriseId"] as? Int else { return "" }
            return Environment.APIBasePath() + "doo/enterprise/user/toggle/\(id)/\(flag)/\(enterpriseId)"
            
        case .reinviteEnterpriseUser(let param):
            guard let id = param["id"] as? Int else { return "" }
            return Environment.APIBasePath() + "doo/enterprise/user/reinvite/\(id)"
        //            return "http://34.196.130.118:30019/doo/enterprise/user/reinvite/\(id)"
        
        case .changeRoleOfEnterpriseUser(let param):
            guard let userId = param["userId"] as? String,
                  let roleId = param["roleId"] as? String,
                  let enterpriseId = param["enterpriseId"] as? String else { return "" }
            return Environment.APIBasePath() + "doo/enterprise/user/change/role/\(userId)/\(roleId)/\(enterpriseId)"
            
            
            
        // Profile
        case .getProfileData:
            return Environment.APIBasePath() + "doo/protected/user/profile"
        case .getDefaultAvatars:
            return Environment.APIBasePath() + "doo/protected/user/profile/avatar"
        case .updateProfileData:
            return Environment.APIBasePath() + "doo/protected/user/profile/update"
        case .updateProfilePicture:
            return Environment.APIBasePath() + "doo/protected/user/profile/picture/update"
        case .deleteProfilePicture:
            return Environment.APIBasePath() + "doo/protected/user/profile/picture/update"
        case .verifyOTPUpdateProfile(let param):
            guard let otpUuid = param["otpUuid"] as? String else { return "" }
            return Environment.APIBasePath() + "doo/protected/user/verify/\(otpUuid)"
        case .resendOTPUpdateProfile(let param):
            guard let otpUuid = param["otpUuid"] as? String else { return "" }
            return Environment.APIBasePath() + "doo/protected/user/resend/\(otpUuid)"
        case .getOtherUserProfileData(let param):
            guard let id = param["id"] as? String else { return "" }
            return Environment.APIBasePath() + "doo/protected/user/profile/\(id)"
        case .deleteEnterpriseUser(let param):
            guard let userId = param["userId"] as? String, let enterpriseId = param["enterpriseId"] else { return "" }
            return Environment.APIBasePath() + "doo/enterprise/user/\(userId)/\(enterpriseId)"
            
        // Device flow
        case .getDeviceTypeList:
            return Environment.APIBasePath() + "doo/device/type"
        case .getDeviceListByType(let param):
            if let userParam = param["userParam"] as? String {
                return Environment.APIBasePath() + "doo/device/gateway/filter/\(userParam)"
            } else {
                return Environment.APIBasePath() + "doo/device/gateway/filter"
            }
        case .getDeviceDetailFromDeviceId(let param):
            guard let deviceId = param["deviceId"] as? String else { return "" }
            return Environment.APIBasePath()+"doo/device/\(deviceId)"
        case .getDeviceDetailFromSerialNumber(let param):
            guard let serialNumber = param["serialNumber"] as? String else { return "" }
            //            return "http://34.196.130.118:30013/platform/device/detail/\(serialNumber)"
            return Environment.APIBasePath()+"doo/device/detail/\(serialNumber)"
            
        case .getGatewayList:
            return Environment.APIBasePath() + "doo/device/gateway"
        case .addDevice:
            return Environment.APIBasePath() + "doo/device"
        case .updateDevice(let param):
            guard let deviceId = param["deviceId"] as? String,
                  let name = param["name"] as? String else { return "" }
            return Environment.APIBasePath()+"doo/device/\(deviceId)/\(name)"
        case .deleteDevice(let param):
            guard let deviceId = param["deviceId"] as? String else { return "" }
            return  Environment.APIBasePath()+"doo/device/delete/\(deviceId)"
        case .applianceToggleEnable(let param):
            guard let applianceId = param["applianceId"] as? String,
                  let flag = param["flag"] as? Bool else { return "" }
            return Environment.APIBasePath()+"doo/device/appliance/toggle/enable/\(applianceId)/\(flag)"
        case .applianceToggleFavourite(let param):
            guard let id = param["id"] as? String,
                  let flag = param["flag"] as? Bool else { return "" }
            return Environment.APIBasePath()+"doo/device/toggle/favourite/\(id)/\(flag)"
        case .getApplianceTypeList:
            return Environment.APIBasePath()+"doo/appliance/type"
        case .updateAppliance:
            return Environment.APIBasePath()+"doo/device/appliance/update"
            
        // Group flow
        case .getAllGroups:
            return Environment.APIBasePath()+"doo/group"
        case .getGroupDetail(let param):
            guard let groupId = param["groupId"] as? Int else { return "" }
            return Environment.APIBasePath()+"doo/group/\(groupId)"
        case .updateGroupName(let param):
            guard let groupId = param["groupId"] as? Int else { return "" }
            return Environment.APIBasePath()+"doo/group/update/name/\(groupId)"
        case .groupEnableDisable(let param):
            guard let groupId = param["groupId"] as? Int else { return "" }
            guard let status = param["status"] as? Bool else { return  ""}
            return Environment.APIBasePath()+"doo/group/\(groupId)/\(status)"
        case .removeGroup(let param):
            guard let groupId = param["groupId"] as? Int else { return "" }
            return Environment.APIBasePath()+"doo/group/\(groupId)"
        case .createGroup:
            return Environment.APIBasePath()+"doo/group"
        case .getAllDevicesForGroup(let param):
            //            guard let enterpriseId = param["enterpriseId"] as? String else { return "" }
            //            return Environment.APIBasePath()+"doo/enterprise/\(enterpriseId)/device/list"
            return Environment.APIBasePath()+"doo/device/enterprise"//"http://doo-api-dev.smartsensesolutions.com:30019/"+"doo/enterprise/\(enterpriseId)/device/list"
        
        case .updateDeviceInGroup(let param):
            guard let groupId = param["groupId"] as? Int else { return "" }
            return Environment.APIBasePath()+"doo/group/update/appliance/\(groupId)"
        case .groupEnterpriseFilter(let param):
            guard let enterpriseId = param["enterpriseId"] as? Int else { return "" }
            return Environment.APIBasePath()+"doo/group/enterprise/filter/\(enterpriseId)"
        case .groupAllDeviceApplienceONOFF(let param):
            guard let groupId = param["groupId"] as? Int else { return "" }
            guard let action = param["action"] as? Int else { return "" }
            return Environment.APIBasePath()+"doocore/v1/group/\(groupId)/action/\(action)"
            
            
        case .deviceApplienceONOFF(let param):
            guard let id = param["applianceId"] as? String else { return "" }
            return Environment.APIBasePath()+"doo/appliance/toggle/on/\(id)"
            
        case .getUserPrivillegsDevicesToEnterprise(let param):
            if let userId = param["userId"] as? String {
                return Environment.APIBasePath()+"doo/user/appliance/list?userId=\(userId)"
            }
            return Environment.APIBasePath()+"doo/user/appliance/list"
            
        case .assignDeviceToUserEnterprise:
            return Environment.APIBasePath()+"doo/user/appliance"
        //            return "http://doo-api-dev.smartsensesolutions.com:30019/"+"doo/user/appliance"
        case .getPrivillegsDevicesByUserIdToEnterprise(let param):
            guard let userId = param["userId"] as? Int else { return "" }
            return Environment.APIBasePath()+"doo/user/appliance/\(userId)"
            
        case .logout:
            return Environment.APIBasePath()+"identity/logout"
        case .scheduleList:
            return Environment.APIBasePath()+"doocore/v1/rule/scheduler/list"
        case .sceneList:
            return Environment.APIBasePath()+"doocore/v1/rule/scene/list"
        case .bindingRuleList:
            return Environment.APIBasePath()+"doocore/v1/rule/binding/list"
        case .bindingRuleEnableDisable(let param):
            guard let status = param["status"] as? Int else { return "" }
            guard let id = param["id"] as? Int else { return "" }
            return Environment.APIBasePath()+"doocore/v1/rule/binding/enable/\(id)/\(status)"
            
        case .scheduleEnableDisable(let param):
            guard let status = param["status"] as? Int else { return "" }
            guard let id = param["id"] as? Int else { return "" }
            return Environment.APIBasePath()+"doocore/v1/rule/scheduler/enable/\(id)/\(status)"
            
        case .deleteSchedule(let param):
            guard let id = param["id"] as? Int else { return "" }
            return Environment.APIBasePath()+"doocore/v1/rule/scheduler/delete/\(id)"
        case .updateSchedule:
            return Environment.APIBasePath()+"doocore/v1/rule/scheduler/update"
            
        case .deleteBindingRule(let param):
            guard let id = param["id"] as? Int else { return "" }
            return Environment.APIBasePath()+"doocore/v1/rule/binding/delete/\(id)"
        case .updateBindingRule:
            return Environment.APIBasePath()+"doocore/v1/rule/binding/update"
            
        case .deleteScene(let param):
            guard let sceneId = param["id"] as? Int else { return "" }
            return Environment.APIBasePath()+"doocore/v1/rule/scene/delete/\(sceneId)"
            
        case .updateScene:
            return Environment.APIBasePath()+"doocore/v1/rule/scene/update"
        case .addBindingRule:
            return Environment.APIBasePath()+"doocore/v1/rule/binding/create"

        case .addScheduler:
            return Environment.APIBasePath()+"doocore/v1/rule/scheduler/create"

        case .getFavouriteList:
            return Environment.APIBasePath()+"doo/appliance/favourite"
            
        case .addScene:
            return Environment.APIBasePath()+"doocore/v1/rule/scene/create"
        case .getDeafultMasterSceneList:
            return "http://doo-api-dev.smartsensesolutions.com:30019/doo/default/scene/list"
        case .excuteScene(let param):
            guard let sceneId = param["id"] as? Int else { return "" }
            return Environment.APIBasePath()+"doocore/v1/rule/scene/delete/\(sceneId)"

            
            
        }
    }
}

extension APIRouter {
    
    var method: HTTPMethod {
        switch self {
        case .resendOTP,
             .countrySelection,
             .resendForgotPassword,
             .getUserSessionInfo,
             .getUserRoles,
             .getProfileData,
             .getDefaultAvatars,
             .resendOTPUpdateProfile,
             .getOtherUserProfileData,
             .getGatewayList,
             .getDeviceDetailFromSerialNumber,
             .getDeviceTypeList,
             .getDeviceDetailFromDeviceId,
             .getApplianceTypeList,
             .getAllGroups,
             .getGroupDetail,
             .getUsersPrivillegsBelongsToEnterprise,
             .getUserPrivillegsDevicesToEnterprise,
             .getPrivillegsDevicesByUserIdToEnterprise,
             .getAllDevicesForGroup,
             .logout,
             .sceneList,
             .bindingRuleList,
             .scheduleList,
             .getDeafultMasterSceneList:
            return .get
            
        case .registerUsingEmail,
             .registerUsingMobileNo,
             .registerUsingPassword,
             .login,
             .loginWithSMS,
             .loginWithSMSOTP,
             .verifyOTP,
             .forgotPassword,
             .verifyOTPForgotPassword,
             .resetPasswordForgotPassword,
             .getEnterprises,
             .getTypesOfEnterprises,
             .addEnterprise,
             .getEnterpriseGroups,
             .inviteEnterpriseUsers,
             .getAllEnterpriseUsers,
             .getUsersBelongsToEnterprise,
             .changePassword,
             .switchEnterprise,
             .enterpriseReceivedInvitations,
             .updateProfilePicture,
             .verifyOTPUpdateProfile,
             .addDevice,
             .getDeviceListByType,
             .applianceToggleFavourite,
             .updateAppliance,
             .createGroup,
             .updateDeviceInGroup,
             .groupEnterpriseFilter,
//             .scheduleList,
//             .bindingRuleList,
             .updateScene,
             .updateSchedule,
             .addBindingRule,
             .addScheduler,
             .getFavouriteList,
             .updateBindingRule,
             .addScene:
            return .post
            
        case .updateEnterprise,
             .acceptRejectReceivedInvitaiton,
             .enableDisableEnterpriseUser,
             .reinviteEnterpriseUser,
             .updateProfileData,
             .deleteEnterpriseUser,
             .changeRoleOfEnterpriseUser,
             .applianceToggleEnable,
             .updateDevice,
             .deleteDevice,
             .assignDeviceToUserEnterprise,
             .updateGroupName,
             .groupEnableDisable,
             .removeGroup,
             .deviceApplienceONOFF,
             .groupAllDeviceApplienceONOFF,
             .bindingRuleEnableDisable,
             .scheduleEnableDisable,
             .deleteSchedule,
             .deleteBindingRule,
             .deleteScene,
             .excuteScene:
            return .put
            
        case .deleteProfilePicture:
            return .delete
        }
    }
}

extension APIRouter {
    
    var parameters: Parameters? {
        switch self {
        case .registerUsingEmail(let param):
            return param
        case .countrySelection(let param):
            return param
        case .registerUsingMobileNo(let param):
            return param
        case .login(var param):
            param.removeValue(forKey: "emailOrMobile")
            return param
        case .loginWithSMS(let param):
            return param
        case .loginWithSMSOTP(_):
            return [:]
        case .verifyOTP(_):
            return nil
        case .registerUsingPassword(let param):
            return param
        case .resendOTP(_):
            return nil
        case .forgotPassword(var param):
            param.removeValue(forKey: "emailOrMobile")
            return param
        case .resendForgotPassword(_):
            return [:]
        case .verifyOTPForgotPassword(_):
            return [:]
        case .resetPasswordForgotPassword(let param):
            return param
        case .changePassword(let param):
            return param
        case .getEnterprises(let param):
            return param
        case .getTypesOfEnterprises(let param):
            return param
        case .addEnterprise(let param):
            return param
        case .updateEnterprise(var param):
            param.removeValue(forKey: "enterpriseId")
            return param
        case .getAllEnterpriseUsers(var param):
            param.removeValue(forKey: "searchText")
            return param
        case .getUsersBelongsToEnterprise(var param):
            param.removeValue(forKey: "enterpriseId")
            return param
        case .inviteEnterpriseUsers(let param):
            return param
        case .getEnterpriseGroups(var param):
            param.removeValue(forKey: "update")
            return param
        case .getUserSessionInfo(_):
            return nil
        case .getUserRoles(_):
            return nil
        case .switchEnterprise(_):
            return nil
        case .enterpriseReceivedInvitations(let param):
            return param
        case .acceptRejectReceivedInvitaiton(_):
            return nil
        case .enableDisableEnterpriseUser(_):
            return nil
        case .reinviteEnterpriseUser(var param):
            param.removeValue(forKey: "id")
            return param
        case .changeRoleOfEnterpriseUser(_):
            return nil
            
        case .getProfileData(_):
            return nil
        case .getDefaultAvatars(_):
            return nil
        case .updateProfileData(let param):
            return param
        case .updateProfilePicture(let param):
            return param
        case .deleteProfilePicture(_):
            return nil
        case .verifyOTPUpdateProfile(var param):
            param.removeValue(forKey: "otpUuid")
            return param
        case .resendOTPUpdateProfile(_):
            return nil
        case .getOtherUserProfileData(_):
            return nil
        case .deleteEnterpriseUser(_):
            return nil
            
        case .getDeviceTypeList(_):
            return nil
        case .getDeviceListByType(var param):
            param.removeValue(forKey: "userParam")
            return param
        case .getDeviceDetailFromDeviceId(_):
            return nil
        case .getDeviceDetailFromSerialNumber(_):
            return nil
        case .getGatewayList(_):
            return nil
        case .addDevice(let param):
            return param
        case .updateDevice(_):
            return nil
        case .deleteDevice(_):
            return nil
        case .applianceToggleFavourite(_):
            return nil
        case .applianceToggleEnable(_):
            return nil
        case .getApplianceTypeList(_):
            return nil
        case .updateAppliance(let param):
            return param
            
        case .getAllGroups(_):
            return nil
        case .getGroupDetail(_):
            return nil
        case .getUsersPrivillegsBelongsToEnterprise(_):
            return nil
            
        case .assignDeviceToUserEnterprise(let param):
            return param
        case .getUserPrivillegsDevicesToEnterprise(_):
            return nil
        case .getPrivillegsDevicesByUserIdToEnterprise(_):
            return nil
            
        case .updateGroupName(let param):
            return param
        case .groupEnableDisable(let param):
            return param
        case .removeGroup(let param):
            return param
        case .createGroup(let param):
            return param
            
        case .getAllDevicesForGroup(var param):
            param.removeValue(forKey: "enterpriseId")
            return nil
        case .updateDeviceInGroup(var param):
            param.removeValue(forKey: "groupId")
            return param
            
        case .groupEnterpriseFilter(_):
            return nil
        case .deviceApplienceONOFF(var param):
            param.removeValue(forKey: "applianceId")
            return param
        case .groupAllDeviceApplienceONOFF(_):
            return nil
        case .logout(_):
            return nil
            
        case .scheduleList(let param):
            return param
        case .sceneList(let param):
            return param
        case .bindingRuleList(let param):
            return param
        case .bindingRuleEnableDisable(let param):
            return param
        case .scheduleEnableDisable(let param):
            return param
        case .deleteSchedule(let param):
            return param
        case .updateSchedule(let param):
            return param
            
        case .deleteBindingRule(_):
            return nil
        case .updateBindingRule(let param):
            return param
        case .addBindingRule(let param):
            return param
            
        case .deleteScene:
            return nil
        case .updateScene(let param):
            return param

        case .addScheduler(let param):
            return param

        case .getFavouriteList(let param):
            return param
        case .addScene(let param):
            return param
        case .getDeafultMasterSceneList:
            return nil
            
        case .excuteScene:
            return nil

            
        }
    }
}

