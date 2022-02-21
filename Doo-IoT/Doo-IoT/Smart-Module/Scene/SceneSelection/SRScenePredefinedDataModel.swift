//
//  SRScenePredefinedDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 19/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
struct SRScenePredefinedDataModel{
    
    var sceneName = ""
    var isSelected = false
    var sceneMasterId = 0
    var sceneIcon = ""
    var iconId = 0
    var isOtherSceneObject = false
    
    //below init will use for pasing from api
    init(param:JSON) {
        self.sceneMasterId = param["masterId"].intValue
        self.sceneName = param["name"].stringValue
        self.iconId = param["iconId"].intValue
        self.sceneIcon = param["icon"].stringValue
        
        // Master id of Other is 1 as discussed with backend team.
        if (self.sceneMasterId == 1) {
            self.isOtherSceneObject = true
        }
    }
}
