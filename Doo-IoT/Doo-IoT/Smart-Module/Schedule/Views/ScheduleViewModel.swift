//
//  ScheduleViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 02/02/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
class ScheduleViewModel {
    
    var arrayScheduerList = [SRSchedulerDataModel]()
    var isSchedulersListFetched: Bool = false
    
    // Pagination work for Binding Rule
    private var totalElements = 0
    var getAvailableElements: Int { return arrayScheduerList.count }
    var getTotalElements: Int { return totalElements }
    private let pageSize = 20
    func getPageDict(_ isFromPullToRefresh: Bool) -> [String: Any] {
        // here 1 for requested list
        func getPageNo() -> Int {
            if isFromPullToRefresh {
                return 1
            } else {
                let passingValue = (getAvailableElements / pageSize) + 1
                debugPrint("Passing value: \(passingValue)")
                return passingValue
            }
        }
        return ["page": getPageNo(), "limit": pageSize]
    }
    
    func removeSelectedObject(id:Int){
        arrayScheduerList.removeAll { (obj) -> Bool in
            if obj.id == id && totalElements > 0{
                totalElements -= 1
            }
            return obj.id == id
        }
    }
        
    
    func removeAllOwnSchedulCreated(){
        arrayScheduerList.removeAll { (obj) -> Bool in
            if obj.viewEditMode == .viewEdit && totalElements > 0{
                totalElements -= 1
            }
            return obj.viewEditMode == .viewEdit
        }
    }

    
    var isAvailableOwnCreatedScheduler:Bool{
        return arrayScheduerList.contains(where: {$0.viewEditMode == .viewEdit})
    }
    //=================== Schedule List =======================
    func callGetScheduleListAPI(param:[String:Any], success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .scheduleList(param), method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                if self.parseScheduleList(jsonResponse, page: param["page"] as? Int ?? 1){
                    success()
                }
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    func parseScheduleList(_ response: [String:JSON], page: Int = 1) -> Bool {
        guard let payload = response["payload"]?.dictionaryValue["data"]?.dictionaryValue, let content = payload["content"]?.arrayValue, let totalElements = payload["pager"]?.dictionaryValue["totalRecord"]?.intValue else { return false }
        debugPrint(content)
        self.totalElements = totalElements
        if page == 1 { arrayScheduerList.removeAll() }
        
        for object in content {
            arrayScheduerList.append(SRSchedulerDataModel.init(param: object))
        }
        return true
    }
    
    func loadStaticData(){
        
        let array:[[String:Any]] = [[
            "createdBy" : 16,
            "scheduleType" : "once",
            "name" : "temp4l23344",
            "enable" : 1,
            "id" : 11,
            "enterpriseId" : 29,
            "appliances" : [
              [
                "applianceId" : 13,
                "scheduleId" : 11,
                "targetValue" : 0,
                "id" : 13,
                "applianceName" : "Appliance_3",
                "targetAccess" : 1,
                "targetAction" : 2
              ]
            ],
            "scheduleDate" : "Sun, 12 Sep 21 06:03:20 GMT+5:30",
            "updatedBy" : 16
          ], [
            "createdBy" : 16,
            "scheduleType" : "daily",
            "name" : "temp",
            "enable" : 1,
            "id" : 10,
            "enterpriseId" : 29,
            "appliances" : [
              [
                "targetAction" : 3,
                "scheduleId" : 10,
                "applianceId" : 12,
                "applianceName" : "Appliance_2",
                "targetValue" : 0,
                "targetAccess" : 2,
                "id" : 12
              ]
            ],
            "scheduleDate" : "Fri, 13 Aug 21 06:27:13 GMT+5:30",
            "updatedBy" : 16
          ], [
            "createdBy" : 16,
            "scheduleType" : "custom",
            "name" : "temp",
            "enable" : 1,
            "id" : 9,
            "enterpriseId" : 29,
            "appliances" : [
              [
                "targetAccess" : 2,
                "applianceName" : "Appliance_2",
                "targetAction" : 3,
                "scheduleId" : 9,
                "targetValue" : 0,
                "id" : 12,
                "applianceId" : 12
              ]
            ],
            "scheduleDate" : "Thu, 11 Aug 22 09:26:45 GMT+5:30",
            "updatedBy" : 16
          ], [
            "createdBy" : 16,
            "scheduleType" : "custom",
            "name" : "temp",
            "id" : 8,
            "enterpriseId" : 29,
            "appliances" : [
              [
                "id" : 6,
                "targetAccess" : 1,
                "targetAction" : 1,
                "scheduleId" : 8,
                "targetValue" : 0,
                "applianceId" : 6,
                "applianceName" : "Appliance_1"
              ]
            ],
            "scheduleDate" : "Wed, 11 Aug 21 12:13:45",
            "updatedBy" : 16
          ]]
        
        arrayScheduerList.removeAll()
        for object in array {
            arrayScheduerList.append(SRSchedulerDataModel.init(param: JSON.init(object)))
        }
    }
}
