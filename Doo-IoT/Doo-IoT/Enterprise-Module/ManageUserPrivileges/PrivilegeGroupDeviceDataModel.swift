//
//  PrivilegeGroupDeviceDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 09/09/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

// Gruoup of Applience // like panel used when privielges screen come like selecte devcie and assign privielges
import Foundation
struct PrivilegeGroupDeviceDataModel {
    
    var dataId = 0
    var title: String = ""
    var image: String = ""
    var isEnable: Bool = false
    var applianceArray = [ApplianceDataModel]()
    var enumApplianceAction: EnumApplianceAction = .none
    var applienceAction = 0
    var arrayOprationSupported = [EnumApplianceSupportedOpration]()
    var selected = false
    init(jsonObject: JSON) {
        
        if let id = jsonObject["deviceId"].int{
            self.dataId = id
        }else if let id = jsonObject["applianceId"].int{
            self.dataId = id
        }
        
        self.title = jsonObject["name"].stringValue
        self.image = jsonObject["applianceTypeImage"].stringValue
        self.selected = jsonObject["selected"].boolValue
        
        self.applianceArray.removeAll()
        if let array = jsonObject["appliance"].array {
            for obj in array.enumerated(){
                let applObj = ApplianceDataModel.init(fromPrivilege: JSON.init(obj.element))
                self.applianceArray.append(applObj)
            }
        }
        
        let oprationArray = jsonObject["operations"].arrayValue.map({EnumApplianceSupportedOpration.init(rawValue: $0.intValue) ?? .none})
        if oprationArray.count != 0 {
            self.arrayOprationSupported = oprationArray
        }
        
        if let str = jsonObject["operationData"].string, let convertedJson  = Utility.convertToDictionary(text: str){
            let operationData = JSON.init(convertedJson)
            
            if  let action = operationData["action"].int, action != 0{
                self.enumApplianceAction = EnumApplianceAction.init(rawValue: action) ?? .none
                self.applienceAction = action
            }else{
                // default 1
                self.enumApplianceAction = .onOff
                self.applienceAction = 1
            }
        }
    }
}
