//
//  ApplianceDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 26/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

enum EnumApplianceAction: Int {
    case none = 0, onOff, fan, rgb
}

enum EnumApplianceSupportedOpration:Int {
    case none = 0, on, off, na, fan, rgb
    
    var action:Int{
        switch self {
        case .fan:
            return 2
        case .rgb:
            return 3
        case .on, .off:
            return 1
        default:
            return 0
        }
    }
}


//var applianceId = 0
//var title: String = ""
//var onOffStatus: Bool = false
//var selected = true
//var isMarked = true
//var operationsArray = [EnumApplianceSupportedOpration]()
//var enumApplianceAction: EnumApplianceAction = .none
//var applienceAction = 0

class ApplianceDataModel {
    
    var deviceType: Int = 1
    var online: Bool = false
    var isMore: Bool = false
    var isLess: Bool = false
    var image: String {
        if isMore {
            return "imgArrowDown"
        } else if isLess {
            return "imgArrowUp"
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
    
    init(isMore: Bool) {
        self.isMore = isMore
        self.applianceName = localizeFor("more")
    }
    
    init(isLess: Bool) {
        self.isLess = isLess
        self.applianceName = localizeFor("less")
    }
    
    var id = ""
    var applianceTypeId = 0
    var applianceName = ""
    var isFavourite: Bool = false
//    var isEnabled = false
    var accessStatus = false  // for toggle access use this one
    var isReadyToCommunication = false // check active flag from backed
    
    //from group
    var groupApplianceId = ""
    var onOffStatus = false
    var isSelected = false
    var speed = 0
    var applianceColor:UIColor! = UIColor.red
    var enumApplianceAction: EnumApplianceAction = .none
    var applianceTypeImage = ""
    var endpointId = 0
    var deviceStatus = false // for online or offline

    var fanSpeedPercentage:Int {
        return speed.getPercentageSpeed()
    }
    var applianceTypeName = ""
    var arrayOprationSupported = [EnumApplianceSupportedOpration]()
    func checkApplianceTypeSupportedOrNot(enumType:EnumApplianceSupportedOpration) -> Bool {
        return arrayOprationSupported.contains(enumType)
    }
    
    var applienceAction = 0
    init(id: Int, title: String, deviceType: Int, online: Bool, enumOpration: EnumApplianceAction, onOffStatus: Bool) {
        self.id = "\(id)"
        self.applianceName = title
        self.deviceType = deviceType
        self.online = online
        self.enumApplianceAction = enumOpration
        self.onOffStatus = onOffStatus
    }
    
    init(dict: JSON) {
        if let ids = dict["id"].int{
            id  = String(ids)
        }else if let applinceId = dict["applianceId"].string{
            id = applinceId
        }else if let applinceId = dict["applianceId"].int{
            id = String(applinceId)
        }
        applianceName = dict["name"].stringValue
        applianceTypeName = dict["applianceTypeName"].stringValue
        commonParsing(param: dict)
    }
    
    init(fromGroupMain dict: JSON) {
        
        onOffStatus = dict["onOffStatus"].boolValue
        isSelected = dict["selected"].boolValue
        applianceName = dict["name"].stringValue
        // below key are noti comming while fetching group detail
        groupApplianceId = dict["groupApplianceId"].stringValue
        applianceTypeName = dict["applianceTypeName"].stringValue
        
        if let ids = dict["id"].int{
            id  = String(ids)
        }else if let applinceId = dict["applianceId"].string{
            id = applinceId
        }else if let applinceId = dict["applianceId"].int{
            id = String(applinceId)
        }
        commonParsing(param: dict)
    }
    
    var macAddress = ""
    init(fromFavourite dict: JSON) {
        
        applianceTypeImage = dict["applianceImage"].stringValue
        applianceName = dict["applianceName"].stringValue
        onOffStatus = dict["onOffStatus"].boolValue
        macAddress = dict["macAddress"].stringValue
        if let ids = dict["id"].int{
            id  = String(ids)
        }else if let applinceId = dict["applianceId"].string{
            id = applinceId
        }else if let applinceId = dict["applianceId"].int{
            id = String(applinceId)
        }
        commonParsing(param: dict)
    }
    
    func update(dict: JSON) {
        applianceName = dict["name"].stringValue
        id = dict["id"].stringValue
        onOffStatus = dict["deviceStatus"].boolValue // need to check leter
        commonParsing(param: dict)
    }
    
    init(fromPrivilege  dict: JSON) {
        if let ids = dict["id"].int{
            id  = String(ids)
        }else if let applinceId = dict["applianceId"].string{
            id = applinceId
        }else if let applinceId = dict["applianceId"].int{
            id = String(applinceId)
        }
        self.applianceName = dict["name"].stringValue
        self.onOffStatus = dict["onOffStatus"].boolValue
        self.isSelected = dict["selected"].boolValue
        applianceTypeName = dict["applianceTypeName"].stringValue
        commonParsing(param: dict)
    }
    
    func commonParsing(param:JSON){
        deviceStatus = param["deviceStatus"].boolValue
        macAddress = param["macAddress"].stringValue
        applianceTypeId = param["applianceTypeId"].intValue
        if let image = param["applianceTypeImage"].string{
            applianceTypeImage = image
        }else if let image = param["image"].string{
            applianceTypeImage = image
        }
        isFavourite = param["favourite"].boolValue
        accessStatus = param["accessStatus"].boolValue
        isReadyToCommunication = param["active"].boolValue
        endpointId = param["endPointId"].intValue
        
        let oprationArray = param["operations"].arrayValue.map({EnumApplianceSupportedOpration.init(rawValue: $0.intValue) ?? .none})
        if oprationArray.count != 0 {
            self.arrayOprationSupported = oprationArray
        }
        
        if let str = param["operationData"].string, let convertedJson  = Utility.convertToDictionary(text: str){
            let operationData = JSON.init(convertedJson)
            
            if  let action = operationData["action"].int{
                self.enumApplianceAction = EnumApplianceAction.init(rawValue: action) ?? .none
                self.applienceAction = action
                switch enumApplianceAction {
                case .fan:
                    setSpeedValueIfApplienceTypeFan(value: operationData["value"].intValue)
                case .rgb:
                    setRGBValueIfApplienceTypeRGB(value: operationData["value"].intValue)
                case .onOff, .none:
                    setSpeedValueIfApplienceTypeFan(value: operationData["value"].intValue)
                    setRGBValueIfApplienceTypeRGB(value: operationData["value"].intValue)
                }
            }
        }
    }
    
    private func setSpeedValueIfApplienceTypeFan(value:Int){
        if arrayOprationSupported.contains(.fan){
            if value > 0{
                self.speed = value.getSpeedFromPercentage()
            }else{
                self.speed = 0
            }
        }
    }
    
     func setRGBValueIfApplienceTypeRGB(value:Int){
        if arrayOprationSupported.contains(.rgb){
            var hexColor = String(value, radix: 16)
            let hexColorWithoutHash = hexColor.replacingOccurrences(of: "#", with: "")
            let leftPadingZero = 6 - hexColorWithoutHash.count
            var paddingZeroStr = ""
            if leftPadingZero > 0{
                
                for _ in 1...leftPadingZero {
                    paddingZeroStr += "0"
                }
                // apended zero left padding when hex code count less than 6
                if !paddingZeroStr.isEmpty {
                    hexColor = paddingZeroStr+hexColor
                }
            }
            applianceColor = UIColor.init(hex: hexColor)
        }
    }
}
