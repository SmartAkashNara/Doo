//
//  SmartAddTargetViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 29/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
class SmartAddTargetViewModel{
    
    // Condition handler
    var currentSelectedCondition: DooBottomPopupGenericDataModel? = nil
    var listOfCondition: [DooBottomPopupGenericDataModel] = []
    
    init() {
        preparedSpeedLevelArray()
    }
    
    func preparedSpeedLevelArray() {
        
        listOfCondition.removeAll()
        listOfCondition.append(DooBottomPopupGenericDataModel.init(dataId: "\(EnumFanSpeed.fast.value)", dataValue: EnumFanSpeed.fast.title))
        listOfCondition.append(DooBottomPopupGenericDataModel.init(dataId: "\(EnumFanSpeed.medium.value)", dataValue: EnumFanSpeed.medium.title))
        listOfCondition.append(DooBottomPopupGenericDataModel.init(dataId: "\(EnumFanSpeed.slow.value)", dataValue: EnumFanSpeed.slow.title))
        listOfCondition.append(DooBottomPopupGenericDataModel.init(dataId: "\(EnumFanSpeed.verySlow.value)", dataValue: EnumFanSpeed.verySlow.title))
//        listOfCondition.append(DooBottomPopupGenericDataModel.init(dataId: "\(EnumFanSpeed.medium.value)", dataValue: EnumFanSpeed.medium.title))
    }
}
