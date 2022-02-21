//
//  DeviceTypeDataModel.swift
//  Doo-IoT
//
//  Created by Akash on 26/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
struct DeviceTypeDataModel {
    var productTypeId = ""
    var name = ""
    var image = ""
    var code = ""
    var createdAt = 0
    var updatedAt = 0
    var deviceCount = 0
    var gateway = false

    init(dict: JSON) {
        productTypeId = dict["productTypeId"].stringValue
        name = dict["name"].stringValue
        image = dict["image"].stringValue
        code = dict["code"].stringValue
        createdAt = dict["createdAt"].intValue
        updatedAt = dict["updatedAt"].intValue
        deviceCount = dict["deviceCount"].intValue
        gateway = dict["gateway"].boolValue
    }
}
