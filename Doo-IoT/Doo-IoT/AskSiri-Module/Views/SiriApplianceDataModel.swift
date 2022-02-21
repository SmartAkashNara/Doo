//
//  SiriApplianceDataModel.swift
//  Doo-IoT
//
//  Created by Shraddha on 23/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class SiriApplianceDataModel {
 
    var groupDetail: GroupDataModel? = nil
    var arraySiriAppliances = [TargetApplianceDataModel]()
    
    init(param: JSON) {
        if let arrayAppliances = param["appliances"].array {
            arraySiriAppliances.removeAll()
            arrayAppliances.forEach { (objJson) in
                arraySiriAppliances.append(TargetApplianceDataModel.init(paramForSiriAppliance: objJson))
            }
        }
        self.groupDetail = GroupDataModel.init(dict: param["groups"])
    }
}
