//
//  DevicesListViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class DevicesTypesListViewModel {
    
    
    var deviceTypes = [DeviceTypeDataModel]()
    func callGetDeviceTypeListAPI(_ success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {

        API_SERVICES.callAPI(path: .getDeviceTypeList, method:.get) { [weak self] (parsingResponse) in
            if let json = parsingResponse, ((self?.parseDeviceTypeList(json)) != nil){
                success()
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    func parseDeviceTypeList(_ response: [String:JSON]) -> Bool {
        guard let arrayDeviceTypes = response["payload"]?.array else { return false }
        deviceTypes.removeAll()
        for deviceType in arrayDeviceTypes {
            let device = DeviceTypeDataModel(dict: deviceType)
            if device.deviceCount != 0 {
                deviceTypes.append(device)
            }
        }
        return true
    }
}
