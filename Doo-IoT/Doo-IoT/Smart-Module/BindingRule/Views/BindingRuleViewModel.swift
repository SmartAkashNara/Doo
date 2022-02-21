//
//  BindingRuleViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 02/02/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class BindingRuleViewModel {
    
    // list
    var arrayBindingRuleList = [SRBindingRuleDataModel]()
    var isBindingRulesListFetched: Bool = false
    
    // Pagination work for Binding Rule
    private var totalElements = 0
    var getAvailableElements: Int { return arrayBindingRuleList.count }
    var getTotalElements: Int { return totalElements }
    private let pageSize = 20
    
    func getPageDict(_ isFromPullToRefresh: Bool) -> [String: Any] {
        // here 1 for requested list
        func getPageNo() -> Int {
            if isFromPullToRefresh {
                return 0
            } else {
                let passingValue = (getAvailableElements / pageSize) + 1
                debugPrint("Passing value: \(passingValue)")
                return passingValue
            }
        }
        return ["page": getPageNo(), "limit": pageSize]
    }
    
    func removeSelectedObject(id:Int){
        arrayBindingRuleList.removeAll { (obj) -> Bool in
            if obj.id == id && totalElements > 0{
                totalElements -= 1
            }
            return obj.id == id
        }
    }
    
    func callGetAllBindingRuleAPI(param:[String:Any], success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .bindingRuleList(param), method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                self.parseBindingRule(jsonResponse, page: param["page"] as? Int ?? 0)
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
    
    func parseBindingRule(_ response: [String:JSON], page: Int = 0) -> Bool {
        guard let payload = response["payload"]?.dictionaryValue["data"]?.dictionaryValue,
              let arrayContent = payload["content"]?.arrayValue,
              let totalElements = payload["pager"]?.dictionaryValue["totalRecord"]?.intValue else { return false }
        debugPrint(arrayContent)
        self.totalElements = totalElements
        if page == 0 { arrayBindingRuleList.removeAll() }
        
        for object in arrayContent {
            arrayBindingRuleList.append(SRBindingRuleDataModel.init(param: object))
        }
        return true
    }
    
    func loadStaticData(){
        let array:[[String:Any]] = [[
            "startTime" : "12:00 AM",
            "id" : 87,
            "endTime" : "12:00 AM",
            "triggerAction" : 2,
            "appliances" : [
                [
                    "applianceName" : "Appliance 11",
                    "targetValue" : 0,
                    "targetAction" : 2,
                    "id" : 11,
                    "bindingRuleId" : 87,
                    "applianceId" : 11,
                    "targetAccess" : 1
                ],
                [
                    "applianceName" : "Appliance_4",
                    "targetValue" : 0,
                    "targetAction" : 2,
                    "id" : 89,
                    "bindingRuleId" : 87,
                    "applianceId" : 89,
                    "targetAccess" : 1
                ]
            ],
            "triggerId" : 89,
            "enterpriseId" : 29,
            "name" : "Fan-Test112",
            "enable" : 1,
            "updatedBy" : 16,
            "createdBy" : 16,
            "triggerName" : "Appliance_4"
        ], [ "appliances" : [[
            "targetValue" : 0,
            "bindingRuleId" : 85,
            "targetAccess" : 1,
            "targetAction" : 1,
            "applianceName" : "Appliance 11",
            "id" : 11,
            "applianceId" : 11
        ]
        ],
        "updatedBy" : 0,
        "startTime" : "02:41 PM",
        "name" : "RGB",
        "createdBy" : 16,
        "enable" : 1,
        "triggerId" : 11,
        "endTime" : "02:41 PM",
        "triggerName" : "Appliance 11",
        "triggerAction" : 2,
        "id" : 85,
        "enterpriseId" : 29
        ], [ "appliances" : [[
            "targetValue" : 0,
            "applianceId" : 11,
            "bindingRuleId" : 84,
            "targetAction" : 1,
            "id" : 11,
            "targetAccess" : 1,
            "applianceName" : "Appliance 11"
        ],
        [
            "targetAction" : 1,
            "bindingRuleId" : 84,
            "id" : 11,
            "targetValue" : 0,
            "targetAccess" : 1,
            "applianceName" : "Appliance 11",
            "applianceId" : 11
        ]
        ],
        "updatedBy" : 16,
        "startTime" : "10:20 AM",
        "name" : "Aaa",
        "createdBy" : 16,
        "enable" : 1,
        "triggerId" : 11,
        "endTime" : "10:20 AM",
        "triggerName" : "Appliance 11",
        "triggerAction" : 1,
        "id" : 84,
        "enterpriseId" : 29
        ], [ "appliances" : [[
            "targetAction" : 1,
            "applianceId" : 88,
            "bindingRuleId" : 80,
            "id" : 88,
            "applianceName" : "Appliance_3",
            "targetValue" : 1,
            "targetAccess" : 1
        ],
        [
            "targetAction" : 1,
            "applianceId" : 88,
            "bindingRuleId" : 80,
            "id" : 88,
            "applianceName" : "Appliance_3",
            "targetValue" : 0,
            "targetAccess" : 1
        ],
        [
            "targetAction" : 2,
            "applianceId" : 89,
            "bindingRuleId" : 80,
            "id" : 89,
            "applianceName" : "Appliance_4",
            "targetValue" : 0,
            "targetAccess" : 2
        ],
        [
            "targetAction" : 3,
            "applianceId" : 88,
            "bindingRuleId" : 80,
            "id" : 88,
            "applianceName" : "Appliance_3",
            "targetValue" : 0,
            "targetAccess" : 3
        ]
        ],
        "updatedBy" : 16,
        "startTime" : "05:32 PM",
        "name" : "test1",
        "createdBy" : 16,
        "enable" : 1,
        "triggerId" : 88,
        "endTime" : "06:32 PM",
        "triggerName" : "Appliance_3",
        "triggerAction" : 3,
        "id" : 80,
        "enterpriseId" : 29
        ]]
        arrayBindingRuleList.removeAll()
        for object in array {
            arrayBindingRuleList.append(SRBindingRuleDataModel.init(param: JSON.init(object)))
        }
    }
}
