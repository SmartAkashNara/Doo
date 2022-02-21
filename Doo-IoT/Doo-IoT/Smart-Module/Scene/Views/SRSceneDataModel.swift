//
//  SRSceneDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 19/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

enum SRViewEditMode : Int {
    case viewOnly = 0
    case viewEdit
}

class SRSceneDataModel {
    
    var enable = false
    var sceneName = ""
    var id = 0
    var arrayTargetApplience = [TargetApplianceDataModel]()
    var targetApplienceCount = ""
    var sceneIcon = ""
    var scenePredefinedDataModel: SRScenePredefinedDataModel? = nil
    var iconId = 0
    var viewEditMode : SRViewEditMode = .viewOnly
    var isFavouriteScene = false
    var favouriteIcon:String{
        isFavouriteScene ? "imgHeartFavouriteFill" : "imgHeartFavouriteUnfill"
    }
    
    var isAddedToSiri = false
    var shortcutUUID = UUID().uuidString
    
    init(param:JSON) {
        self.id = param["id"].intValue
        self.sceneName = param["name"].stringValue
        
        self.sceneIcon = param["icon"].stringValue
        self.enable = param["enable"].intValue == 1 ? true : false
        self.iconId = param["iconId"].intValue
        self.isFavouriteScene = param["favouite"].intValue == 1 ? true : false
        
        if param["mode"].intValue  == 1{
            self.viewEditMode = SRViewEditMode.viewEdit
        } else {
            self.viewEditMode = SRViewEditMode.viewOnly
        }
        if let arrayAppliances = param["appliances"].array{
            arrayTargetApplience.removeAll()
            arrayAppliances.forEach { (objJson) in
                arrayTargetApplience.append(TargetApplianceDataModel.init(param: objJson))
            }
        }
        
        let str  = arrayTargetApplience.count > 1 ? localizeFor("target_appliances") : localizeFor("target_appliance")
        targetApplienceCount = "\(arrayTargetApplience.count) \(str)"
        self.scenePredefinedDataModel = SRScenePredefinedDataModel.init(param: param)
    }
    
    init(withScenePredefined dataModel: SRScenePredefinedDataModel) {
        self.scenePredefinedDataModel = dataModel
    }
}
