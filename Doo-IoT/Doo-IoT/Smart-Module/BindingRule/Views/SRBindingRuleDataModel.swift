//
//  SRBindingRuleDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 19/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
struct SRBindingRuleDataModel{
    enum EnumConditionAction:Int {
        case equal = 1, less = 2, greater = 4
        
        var title:String{
            switch self {
            case .equal:
                return "=  Equal to"
            case .less:
                return "<  Less than"
            case .greater:
                return ">  Greater than"
            }
        }
    }
    
    var id = 0
    var triggerId = 0
    var enable = false
    var bindingRuleName = ""
    var triggerName = ""
    var startTime = ""
    var endTime = ""
    var fullTime:String{
        var str = startTime
        if !endTime.isEmpty{
            str = startTime+" - "+endTime
        }
        return str
    }
    var applineceIcon = ""
    var targetApplienceCount = ""
    var arrayTargetApplience = [TargetApplianceDataModel]()
    var objEnumTriggerAction:EnumTriggerAction = .on
    var objEnumConditionAction:EnumConditionAction = .equal
    var viewEditMode : SRViewEditMode = .viewOnly
    
    init(param:JSON) {
        
        self.triggerName = param["triggerName"].stringValue
        self.bindingRuleName = param["name"].stringValue
        self.id = param["id"].intValue
        self.triggerId = param["triggerId"].intValue
        self.startTime = param["startTime"].stringValue.lowercased()
        self.endTime = param["endTime"].stringValue.lowercased()
        self.objEnumTriggerAction = EnumTriggerAction.init(rawValue: param["triggerAction"].intValue) ?? .off
        self.enable = param["enable"].intValue == 1 ? true : false
        
        if let arrayAppliances = param["appliances"].array{
            arrayTargetApplience.removeAll()
            arrayAppliances.forEach { (objJson) in
                arrayTargetApplience.append(TargetApplianceDataModel.init(param: objJson))
            }
        }
        
        if param["mode"].intValue  == 1{
            self.viewEditMode = SRViewEditMode.viewEdit
        } else {
            self.viewEditMode = SRViewEditMode.viewOnly
        }
        let str  = arrayTargetApplience.count > 1 ? localizeFor("target_appliances") : localizeFor("target_appliance")
        targetApplienceCount = "\(arrayTargetApplience.count) \(str)"
    }
}
