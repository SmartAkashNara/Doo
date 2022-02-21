//
//  GroupDataModel.swift
//  Doo-IoT
//
//  Created by Shraddha on 09/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation


class GroupDataModel {
    // Added new by Shraddha //
    var devices : [DeviceDataModel] = []
    
    // ***** //
    enum EnumGroupType:Int {
        case masterGroup, simpleGroup
    }
    
    var enumGroupType: EnumGroupType{
        if let groupMasterId = groupMasterId {
            if groupMasterId.isEmpty || groupMasterId == "-1" || groupMasterId == "0"{
                return .simpleGroup
            }else{
                return .masterGroup
            }
        }else{
            return .simpleGroup // if not group master id, send simple group
        }
    }
    
    //    var title: String = ""
    var deviceType: Int? = 1
    var online: Bool? = false
    var isMore: Bool? = false
    var image: String? {
        if isMore ?? false {
            return "imgArrowDown"
        } else {
            switch deviceType {
            case 1: return "imgFanOn"
            case 2: return "imgLightOn"
            case 3: return "imgACOff"
            default: return ""
            }
        }
    }
    
    init() {}
    
    init(id: Int, title: String, deviceType: Int, online: Bool) {
        self.id = id
        self.name = title
        self.deviceType = deviceType
        self.online = online
    }
    
    init(isMore: Bool) {
        self.isMore = isMore
        self.name = localizeFor("more")
    }
    
    var id = 0
    var enterpriseId : String?
    var name = ""
    var groupMasterId : String?
    var enable: Bool? = false
    var deleted: Bool? = false
    
    var bannerImage : String?
    var tabSelected: Bool = false
    
    init(id: Int, title: String, deviceType: Int, enable: Bool, devices: [DeviceDataModel], strBannerImg: String) {
        self.id = id
        self.name = title
        self.deviceType = deviceType
        self.enable = enable
        self.devices = devices
        self.bannerImage = strBannerImg
    }
    
    init(dict: JSON) {
        id = dict["id"].intValue
        name = dict["name"].stringValue
        
        enterpriseId = dict["enterpriseId"].stringValue
        groupMasterId = dict["groupMasterId"].stringValue
        enable = dict["enable"].boolValue
        deleted = dict["deleted"].boolValue
        
        /*
        var bannerIcon = ""
        if let icon = dict["image"].string{
            bannerIcon = icon
        }else{
            bannerIcon = Utility.getRandomBannerImageName() ?? ""
        }
 */
        bannerImage = Utility.getRandomBannerImageName()
        
        if let deviceArray  = dict["device"].array{
            parseDevices(arrayDevices: deviceArray)
        }
        
        if let applianceArray  = dict["appliance"].array{
            parseDevices(arrayDevices: applianceArray)
        }
    }
    
    init(group: EnterpriseGroup) {
        id = group.id
        name = group.name
        
        enterpriseId = String(group.enterpriseTypeId)
        groupMasterId = String(group.groupMasterId)
        enable = group.enable
        
        /*
        var bannerIcon = ""
        if let icon = dict["image"].string{
            bannerIcon = icon
        }else{
            bannerIcon = Utility.getRandomBannerImageName() ?? ""
        }
 */
        bannerImage = Utility.getRandomBannerImageName()
    }
    
    init(withGroupList  dict: JSON) {
        id = dict["id"].intValue
        name = dict["name"].stringValue
        
        enterpriseId = dict["enterpriseId"].stringValue
        groupMasterId = dict["groupMasterId"].stringValue
        enable = dict["enable"].boolValue
        deleted = dict["deleted"].boolValue
        
        /*
        var bannerIcon = ""
        if let icon = dict["image"].string{
            bannerIcon = icon
        }else{
            bannerIcon = Utility.getRandomBannerImageName() ?? ""
        }
 */
        bannerImage = Utility.getRandomBannerImageName() ?? ""
    }
    
    func parseDevices(arrayDevices: [JSON]) {
        devices.removeAll()
        arrayDevices.forEach { (device) in
            //            applinces.append(DeviceDataModel(fromGroupdDetail: device))
            devices.append(DeviceDataModel.init(fromGroupMain: device))
        }
    }
}
