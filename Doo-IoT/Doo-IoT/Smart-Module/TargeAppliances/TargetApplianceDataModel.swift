//
//  TargetApplianceDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 09/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
import Intents

struct ApplianceSiriActionDetails {
    var shortcutUUID = UUID().uuidString
    var isAddedToSiri: Bool = false
    var commandType:EnumActionType = .unknown
}

enum EnumFanSpeed: Int {
//    case verySlow = 1, slow, medium, high, veryHigh
    case verySlow = 1, slow, medium, fast
    
    var title:String{
        switch self {
        case .verySlow:
            return localizeFor("very_slow")
        case .slow:
            return localizeFor("slow")
//        case .medium:
//            return localizeFor("medium")
        case .medium:
            return localizeFor("medium")
        case .fast:
            return "Fast"
        }
    }
    
    /*
    var value:Int{
        switch self {
        case .verySlow:
            return 30
        case .slow:
            return 40
        case .medium:
            return 45
        case .high:
            return 50
        case .veryHigh:
            return 100
        }
    }*/
    
    var value:Int{
        switch self {
        case .verySlow:
            return 30
        case .slow:
            return 40
//        case .medium:
//            return 45
        case .medium:
            return 50
        case .fast:
            return 100
        }
    }
}

enum EnumTargetAccess: Int {
    case disable = 0, enable, na
    
    var indexValue: Int {
        switch self {
        case .na:
            return 0
        case .enable:
            return 1
        case .disable:
            return 2
        }
    }
    var title:String{
        switch self {
        case .na:
            return "N/A"
        case .enable:
            return "Enable"
        case .disable:
            return "Disable"
        }
    }
    
    var textColor: UIColor{
        switch self {
        case .na:
            return .blueHeading
        case .enable:
            return .greenInvited
        case .disable:
            return .textFieldErrorColor
        }
    }
}

enum EnumTargetActionValue: Int {
    case off = 0, on, na
    
    var title:String{
        switch self {
        case .na:
            return "N/A"
        case .on:
            return "ON"
        case .off:
            return "OFF"
        }
    }
    
    var textColor: UIColor{
        switch self {
        case .na:
            return .blueHeading
        case .on:
            return .greenInvited
        case .off:
            return .textFieldErrorColor
        }
    }
}

enum EnumTriggerAction: Int {
    case on = 1, off, compare
    
    var title:String{
        switch self {
        case .on:
            return "ON"
        case .off:
            return "OFF"
        case .compare:
            return "COMPARE"
        }
    }
}

class TargetApplianceDataModel {
    
    var applianceName  = ""
    var targetAccess = 0 // enable, disbale,na
    var targetAction = 0 // 1,2,3 onoff, fan, rgb
    //    var rgb = ""
    //    var speed:Int?
    var targetValue = 0 // on,off,na
    var applianceId = 0
    var id = 0
    var operationsArray = [EnumApplianceSupportedOpration]()
    var applianceImage = ""
    var deviceName = "--"
    var enumApplianceAction: EnumApplianceAction = .none
    var applianceColor:UIColor! = .red
    
    var accessDisplay:String {
        return  EnumTargetAccess.init(rawValue: targetAccess)?.title ?? ""
    }
    var actionValueDisplay:String{
        return  EnumTargetActionValue.init(rawValue: targetValue)?.title ?? ""
    }
    var fanSppedDisplay:String{
        return EnumFanSpeed.init(rawValue: targetValue)?.title ?? ""
    }
    
    func checkApplianceTypeSupportedOrNot(enumType:EnumApplianceSupportedOpration) -> Bool {
        return operationsArray.contains(enumType)
    }
    var applienceAction = 0
    
    // Siri Appliances
    var enterpriseId: Int = 0
    var deviceId: Int = 0
    var applianceTypeId: Int = 0
    var accessStatus: Bool = false
    var onOffStatus: Bool = false
    var endpointId: Int = 0
    var active: Bool = false
    var deleted: Bool = false
    var speedOfFanForSiri: Int = 0
    var rgbForSiri: Int = 0
    
    var arrOperationsForIntent: [ApplianceSiriActionDetails] = [ApplianceSiriActionDetails.init(shortcutUUID: "", isAddedToSiri: false, commandType: .on),
        ApplianceSiriActionDetails.init(shortcutUUID: "", isAddedToSiri: false, commandType: .off),
        ApplianceSiriActionDetails.init(shortcutUUID: "", isAddedToSiri: false, commandType: .fanspeed),
        ApplianceSiriActionDetails.init(shortcutUUID: "", isAddedToSiri: false, commandType: .rgb)]
    
    init(param:JSON) {
        self.deviceName = param["deviceName"].stringValue
        self.applianceName = param["applianceName"].stringValue
        self.targetAccess = param["targetAccess"].intValue
        self.targetAction = param["targetAction"].intValue
        self.targetValue = param["targetValue"].intValue
        self.applianceId = param["applianceId"].intValue
        self.id = param["id"].intValue
        self.applianceImage = param["applianceImage"].stringValue
        self.enumApplianceAction = EnumApplianceAction.init(rawValue: targetAction) ?? .none
        let oprationArray = param["operations"].arrayValue.map({EnumApplianceSupportedOpration.init(rawValue: $0.intValue) ?? .none})
        if oprationArray.count != 0 {
            self.operationsArray = oprationArray
        }
        
        self.setupFanAndRGBValueBasedOnAction(targetAction: self.targetAction, value: self.targetValue)
        if let str = param["operationData"].string, let convertedJson  = Utility.convertToDictionary(text: str){
            let operationData = JSON.init(convertedJson)
            
            setupFanAndRGBValueBasedOnAction(targetAction: operationData["action"].int, value: operationData["value"].intValue)
            
        }
    }
    
    init(paramForSiriAppliance:JSON) {
        self.applianceId = paramForSiriAppliance["applianceId"].intValue
        self.enterpriseId = paramForSiriAppliance["enterpriseId"].intValue
        self.deviceId = paramForSiriAppliance["deviceId"].intValue
        self.applianceTypeId = paramForSiriAppliance["applianceTypeId"].intValue
        self.applianceName = paramForSiriAppliance["name"].stringValue
        self.accessStatus = paramForSiriAppliance["accessStatus"].boolValue
        self.onOffStatus = paramForSiriAppliance["onOffStatus"].boolValue
        self.endpointId = paramForSiriAppliance["endpointId"].intValue
        self.active = paramForSiriAppliance["active"].boolValue
        self.deleted = paramForSiriAppliance["deleted"].boolValue
        
        self.enumApplianceAction = EnumApplianceAction.init(rawValue: targetAction) ?? .none
        let oprationArray = paramForSiriAppliance["operations"].arrayValue.map({EnumApplianceSupportedOpration.init(rawValue: $0.intValue) ?? .none})
        if oprationArray.count != 0 {
            self.operationsArray = oprationArray
        }
        
        self.setupFanAndRGBValueBasedOnAction(targetAction: self.targetAction, value: self.targetValue)
        if let str = paramForSiriAppliance["operationData"].string, let convertedJson  = Utility.convertToDictionary(text: str){
            let operationData = JSON.init(convertedJson)
            setupFanAndRGBValueBasedOnAction(targetAction: operationData["action"].int, value: operationData["value"].intValue)
        }
        
        
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts(completion: { (voiceShortcutsFromCenter, error) in
            if let voiceShortcuts = voiceShortcutsFromCenter {
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.applianceId as? Int == self.applianceId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.actionTypeForIntent == .on}) {
                    self.arrOperationsForIntent[0].isAddedToSiri = true
                    self.arrOperationsForIntent[0].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.arrOperationsForIntent[0].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.applianceId as? Int == self.applianceId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.actionTypeForIntent == .off}) {
                    self.arrOperationsForIntent[1].isAddedToSiri = true
                    self.arrOperationsForIntent[1].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.arrOperationsForIntent[1].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.applianceId as? Int == self.applianceId && ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.actionTypeForIntent == .fanspeed}) {
                    self.arrOperationsForIntent[2].isAddedToSiri = true
                    self.arrOperationsForIntent[2].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.arrOperationsForIntent[2].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionRgbIntent)?.applianceId as? Int == self.applianceId && ($0.shortcut.intent as? ApplianceActionRgbIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionRgbIntent)?.actionTypeForIntent == .rgb}) {
                    self.arrOperationsForIntent[3].isAddedToSiri = true
                    self.arrOperationsForIntent[3].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.arrOperationsForIntent[3].isAddedToSiri = false
                }
                
            } else {
                if let error = error as NSError? {
                    print(error.debugDescription)
                }
            }
        })
        
        
    }
    
    func setupFanAndRGBValueBasedOnAction(targetAction:Int?, value:Int){
        if  let action = targetAction{
            self.enumApplianceAction = EnumApplianceAction.init(rawValue: action) ?? .none
            self.targetAction = action
            switch enumApplianceAction {
            case .fan:
                self.targetValue =  targetValue.getSpeedFromPercentage()
            case .rgb:
                /*
                 var hexColor = String(targetValue, radix: 16)
                 let hexColorWithoutHash = hexColor.replacingOccurrences(of: "#", with: "")
                 let leftPadingZero = 6 - hexColorWithoutHash.count
                 var paddingZeroStr = ""
                 if leftPadingZero > 0{
                 
                 for _ in 1...leftPadingZero {
                 paddingZeroStr += "0"
                 }
                 // apended zero left padding when hex code count less than 6
                 if !paddingZeroStr.isEmpty{
                 hexColor = paddingZeroStr+hexColor
                 }
                 }
                 applianceColor = UIColor.init(hex: hexColor)
                 */
                setColorFromDecimalColorCode()
            default:
                if value > 1 && operationsArray.contains(.fan){
                    self.speedOfFanForSiri = value
                } else  if value > 1 && operationsArray.contains(.rgb){
                    self.rgbForSiri = value
                }
            }
        }
    }
    
    func setColorFromDecimalColorCode(){
        var hexColor = String(targetValue, radix: 16)
        let hexColorWithoutHash = hexColor.replacingOccurrences(of: "#", with: "")
        let leftPadingZero = 6 - hexColorWithoutHash.count
        var paddingZeroStr = ""
        if leftPadingZero > 0{
            
            for _ in 1...leftPadingZero {
                paddingZeroStr += "0"
            }
            // apended zero left padding when hex code count less than 6
            if !paddingZeroStr.isEmpty{
                hexColor = paddingZeroStr+hexColor
            }
        }
        applianceColor = UIColor.init(hex: hexColor)
    }
    
    var getJsonObject:[String:Any]{
        var param:[String:Any] = ["applianceId":self.applianceId,
                                  "targetAccess":self.targetAccess,
                                  "targetAction":self.targetAction]
        switch EnumApplianceAction.init(rawValue: targetAction) ?? .none {
        case .fan:
            param["targetValue"] = self.targetValue.getPercentageSpeed()
        default:
            param["targetValue"] = self.targetValue
        }
        return param
    }
}
