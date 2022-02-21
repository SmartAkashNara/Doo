//
//  UserPrivilegeDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 09/09/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
struct UserPrivilegeDataModel {
    
    var dataId = 0
    var title: String = ""
    var image: String = ""
    var isEnable: Bool = false
    var devices = [PrivilegeGroupDeviceDataModel]()
    var applianceId = 0
    var onOffStatus: Bool = false
    var selected = true

    init(withJSON param:JSON) {
        if let id = param["id"].int{
            self.dataId = id
        }
        if let id = param["deviceId"].int {
            self.dataId = id
        }
        if let id = param["applianceId"].int{
            self.dataId = id
        }
        if let value = param["selected"].bool{
            self.selected = value
        }
        if let status = param["onOffStatus"].bool{
            self.onOffStatus = status
        }
        self.selected = param["selected"].boolValue
        self.title = param["name"].stringValue
        self.image = param["image"].stringValue
        self.isEnable = param["enable"].boolValue
        
        self.devices.removeAll()
        if let array = param["device"].array {
            for obj in array.enumerated(){
                self.devices.append(PrivilegeGroupDeviceDataModel.init(jsonObject: obj.element))
            }
        }
    }
    
    mutating func markItSelected() {
        self.selected = true
    }
}
