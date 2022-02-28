//
//  DevicesListViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class DevicesListViewModel{
    
    var devices = [DeviceDataModel]()
    func callGetDeviceListByTypeAPI(param:[String:Any], searchText:String?, success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        
        API_SERVICES.callAPI(param, path: .getDeviceListByType(searchText)) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let selfStrong = self, selfStrong.parseDeviceListByType(json, page: param["page"] as? Int ?? 0){
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
    
    func parseDeviceListByType(_ response: [String:JSON], page: Int = 0) -> Bool {
        guard let payload = response["payload"]?.dictionaryValue,
              let arrayDevices = payload["content"]?.arrayValue,
              let totalElements = payload["pageable"]?.dictionaryValue["totalElements"]?.intValue else { return false }
        self.totalElements = totalElements
        if page == 0 { devices.removeAll() }
        for device in arrayDevices {
            let device = DeviceDataModel(deviceListDict: device)
            devices.append(device)
        }
        return true
    }
    
    // Pagination work
    private var totalElements = 0
    var getAvailableElements: Int { return devices.count }
    var getTotalElements: Int { return totalElements }
    private let pageSize = 20
    
    func getPageDict(_ isFromPullToRefresh: Bool) -> [String: Any] {
        // here 1 for requested list
        func getPageNo() -> Int {
            if isFromPullToRefresh {
                return 0
            } else {
                return getAvailableElements / pageSize
            }
        }
        return ["page": getPageNo(), "size": pageSize]
    }
}
