//
//  SRSchedulerDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 19/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

enum Weekdays: Int, CaseIterable {
    case Mon = 1, Tue, Wed, Thu, Fri, Sat, Sun
    
    static func getAllWeekdaysInitials() -> String {
        return "MTWTFSS"
    }
    
    func getMMM() -> String{
        switch self {
        case .Mon:
            return "Mon"
        case .Tue:
            return "Tue"
        case .Wed:
            return "Wed"
        case .Thu:
            return "Thu"
        case .Fri:
            return "Fri"
        case .Sat:
            return "Sat"
        case .Sun:
            return "Sun"
        }
    }
    
    func getD() -> String{
        switch self {
        case .Mon:
            return "M"
        case .Tue:
            return "T"
        case .Wed:
            return "W"
        case .Thu:
            return "T"
        case .Fri:
            return "F"
        case .Sat:
            return "S"
        case .Sun:
            return "S"
        }
    }
}

struct SRSchedulerDataModel{
    enum EnumScheduleType:String {
        case once = "once", daily = "daily", custom = "custom"
        var title:String{
            switch self {
            case .once:
                return "Once"
            case .daily:
                return "Daily"
            case .custom:
                return "Custom"
            }
        }
    }
    
    var id = 0
    var scheduleDate = ""
    var scheduleTime = ""
    var targetApplienceCount = ""
    var enable = false
    var schedulerName = ""
    /*
      var startTime = ""
      var endTime = ""
     var fullTime:String{
     var str = startTime
     if !endTime.isEmpty{
     str = startTime+" - "+endTime
     }
     return str
     }
     */
    var enumEnumScheduleType: EnumScheduleType = .daily
    var arrayTargetApplience = [TargetApplianceDataModel]()
    var rangeOfScheduledDays = [NSRange]()
    var scheduleDays: String? = ""
    var viewEditMode : SRViewEditMode = .viewOnly
    
    init(param:JSON) {
        enumEnumScheduleType = EnumScheduleType.init(rawValue: param["scheduleType"].stringValue.lowercased()) ?? .daily
        self.schedulerName = param["name"].stringValue
        self.enable = param["enable"].intValue == 1 ? true : false
        self.id = param["id"].intValue
        self.scheduleDate = param["scheduleDate"].stringValue
        
        if let arrayAppliances = param["appliances"].array{
            arrayTargetApplience.removeAll()
            arrayAppliances.forEach { (objJson) in
                arrayTargetApplience.append(TargetApplianceDataModel.init(param: objJson))
            }
        }
        
        if let convertedDate = param["scheduleDate"].stringValue.getDate(format: .eee_dd_mmm_yyyy_hh_mm_ss_z){
            self.scheduleDate = param["scheduleDate"].stringValue
            self.scheduleTime = convertedDate.getDateInString(withFormat: .timeWithAMPM)
        }
        
        scheduleDays = param["scheduleDays"].stringValue
        
        // Week days range calculation.
        let scheduledDaysInInt = param["scheduleDays"].stringValue.components(separatedBy: ",")
        let scheduledDaysInIntJoint = Weekdays.allCases.map({String($0.rawValue)}).joined()
        for sheduledDay in scheduledDaysInInt {
            if let range = scheduledDaysInIntJoint.range(of: sheduledDay) {
                rangeOfScheduledDays.append(range.nsRange(in: sheduledDay))
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
    
    func getIntArrayDaysToStringDaysArray(daysArray:[String]) -> [String]{
        var arrayDaysInString = [String]()
        for day in daysArray{
            switch day {
            case "1":
                arrayDaysInString.append("M")
            case "2":
                arrayDaysInString.append("T")
            case "3":
                arrayDaysInString.append("W")
            case "4":
                arrayDaysInString.append("T")
            case "5":
                arrayDaysInString.append("F")
            case "6":
                arrayDaysInString.append("S")
            case "7":
                arrayDaysInString.append("S")
            default:
                break
            }
        }
        return arrayDaysInString
    }
}
