//
//  AddDeviceUsingQRCodeViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 24/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class AddDeviceUsingQRCodeViewModel {
    
    var deviceData: DeviceDataModel?
    var isAPIStillWorking: Bool = false
    
    func callGetDeviceDetailFromSerialNumberAPI(serialNumber: String,
                               successBlock: @escaping ()->(),
                               failureMessageBlock: @escaping (String) -> (),
                               failureInform: @escaping () -> ()) {
        API_SERVICES.callAPI(path: .getDeviceDetailFromSerialNumber(serialNumber), method:.get) { (parsingResponse) in
            if let json = parsingResponse, self.parseDeviceDetail(json){
                successBlock()
            }
        } failure: { failureMessage in
            failureMessageBlock(failureMessage ?? "")
        } failureInform: {
            failureInform()
        }
    }

    func parseDeviceDetail(_ response: [String:JSON]) -> Bool {
        guard let payload = response["payload"] else { return false }
        deviceData = DeviceDataModel(dict: payload)
        return true
    }
}
