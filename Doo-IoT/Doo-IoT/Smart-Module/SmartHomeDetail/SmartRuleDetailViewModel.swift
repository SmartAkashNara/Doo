//
//  SmartRuleDetailViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 12/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class SmartRuleDetailViewModel {
    
    // Sections work....
    enum EnumSection: Int {
        case deviceDetail = 0, appliances
        var index: Int {
            switch self {
            case .deviceDetail: return 0
            case .appliances: return 1
            }
        }
    }
    
    struct FirstSectionData {
        var title = ""
        var value = ""
        var color: UIColor = UIColor.blueSwitch
        var isShow = true
    }
    
    var sections = [String]()
    var firstSectionData = [FirstSectionData]()
    var arrayOfApplienceList = [TargetApplianceDataModel]()
    
    func preparedFirstSectionBindingRuleData(srBindingRuleDataModel: SRBindingRuleDataModel?) {
        
        // create sections
        sections = [localizeFor("action")]
        guard let dataModel = srBindingRuleDataModel else {
            return
        }
        
        firstSectionData.append(FirstSectionData.init(title: localizeFor("trigger_appliance"), value: dataModel.triggerName, color: UIColor.blueSwitch))
        firstSectionData.append(FirstSectionData.init(title: localizeFor("trigger_action"), value: dataModel.objEnumTriggerAction.title, color: UIColor.blueSwitch))
        
        if dataModel.objEnumTriggerAction == .compare{
            firstSectionData.append(FirstSectionData.init(title: localizeFor("condition"), value: dataModel.objEnumConditionAction.title, color: UIColor.blueSwitch,isShow: false))
        }
        firstSectionData.append(FirstSectionData.init(title: localizeFor("rule_execution_time"), value: dataModel.fullTime, color: UIColor.blueSwitch))
        
        arrayOfApplienceList = dataModel.arrayTargetApplience
        sections.append(localizeFor("target_appliance"))
    }
    
    func preparedFirstSectionSchedulerData(smartDataModel: SRSchedulerDataModel?) {
        // create sections
        sections = [localizeFor("action")]
        guard let dataModel = smartDataModel else {
            return
        }
        
        firstSectionData.append(FirstSectionData.init(title: localizeFor("Schedule_name"), value: dataModel.schedulerName, color: UIColor.blueSwitch))
        firstSectionData.append(FirstSectionData.init(title: localizeFor("schedule_type"), value: dataModel.enumEnumScheduleType.title, color: UIColor.blueSwitch))
        
        if dataModel.enumEnumScheduleType == .once, !dataModel.scheduleDate.isEmpty, let dt = dataModel.scheduleDate.getDate(format: .eee_dd_mmm_yyyy_hh_mm_ss_z)?.getDateInString(withFormat: .ddSpaceMMspaceYYYY){
            firstSectionData.append(FirstSectionData.init(title: localizeFor("schedule_date"), value: dt, color: UIColor.blueSwitch))
            firstSectionData.append(FirstSectionData.init(title: localizeFor("schedule_time"), value: dataModel.scheduleTime, color: UIColor.blueSwitch))
        }
        if dataModel.enumEnumScheduleType == .custom || dataModel.enumEnumScheduleType == .daily, !dataModel.scheduleTime.isEmpty{
            firstSectionData.append(FirstSectionData.init(title: localizeFor("schedule_time"), value: dataModel.scheduleTime, color: UIColor.blueSwitch))
        }
        arrayOfApplienceList = dataModel.arrayTargetApplience
        sections.append(localizeFor("target_appliance"))
    }
    
    func preparedFirstSectionSceneData(smartDataModel: SRSceneDataModel?) {
        // create sections
        sections = [localizeFor("action")]
        guard let dataModel = smartDataModel else {
            return
        }
        
        firstSectionData.append(FirstSectionData.init(title: localizeFor("scene_name"), value: dataModel.sceneName, color: UIColor.blueSwitch))
        
        arrayOfApplienceList = dataModel.arrayTargetApplience
        sections.append(localizeFor("target_appliance"))
    }
}
