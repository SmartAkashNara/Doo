//
//  GlobalProtocol.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 22/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

// Mark: Used at multiple places...
protocol GroupCreateUpdateIndicationProtocol {
    func addedNewGroup(data:GroupDataModel?)
}
extension GroupCreateUpdateIndicationProtocol {
    func updatedGroup(updatedName: String, groupId:Int) {}
    func recallGroupDetailApi() {}
}
