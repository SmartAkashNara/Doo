//
//  AppliancesListInSiriViewModel.swift
//  Doo-IoT
//
//  Created by Shraddha on 23/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class AppliancesListInSiriViewModel {
    
    init() {}
    var arrayAppliancesListInSiri = [SiriApplianceDataModel]()
    
    var isAppliancesListInSiriFetched: Bool = false
    
    // Pagination work for Binding Rule
    private var totalElements = 0
    var getAvailableElements: Int { return arrayAppliancesListInSiri.count }
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

    // ================== Scene List ===================== //
    func callGetAppliancesListInSiriAPI(param:[String:Any], success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .getAllAppliancesFoSiri, method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                self.parseAppliancesListInSiri(jsonResponse, page: param["page"] as? Int ?? 1)
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
    
    func parseAppliancesListInSiri(_ response: [String: JSON], page:Int) -> Bool {
        guard let payload = response["payload"]?.arrayValue else { return false }
        debugPrint(payload)
//        self.totalElements = totalElements
        debugPrint("page passed: \(page)")
        if page == 1 {
            arrayAppliancesListInSiri.removeAll()
        }
        for objAppliance in payload {
            arrayAppliancesListInSiri.append(SiriApplianceDataModel.init(param: objAppliance))
        }
        return true
    }
    
    // favourite scene list
    func callGetFavouriteSceneListAPI(success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .sceneFavouriteList, method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                self.parseFavouriteScenesList(jsonResponse)
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
    
    func parseFavouriteScenesList(_ response: [String: JSON]) {
        guard let payload = response["payload"]?.dictionaryValue["data"]?.dictionaryValue, let content = payload["content"]?.arrayValue else { return }
        debugPrint(content)
        arrayAppliancesListInSiri.removeAll()
        for objScene in content {
            arrayAppliancesListInSiri.append(SiriApplianceDataModel.init(param: objScene))
        }
    }
    
    func loadStaticData(){
        let array:[[String:Any]] = [[
            "triggerAction" : 2,
            "appliances" : [
                [
                    "applianceId" : 11,
                    "targetAction" : 2,
                    "bindingRuleId" : 87,
                    "targetAccess" : 1,
                    "id" : 11,
                    "targetValue" : 0,
                    "applianceName" : "Appliance 11"
                ],
                [
                    "applianceId" : 89,
                    "targetAction" : 2,
                    "bindingRuleId" : 87,
                    "targetAccess" : 1,
                    "id" : 89,
                    "targetValue" : 0,
                    "applianceName" : "Appliance_4"
                ]
            ],
            "triggerId" : 89,
            "endTime" : "12:00 AM",
            "startTime" : "12:00 AM",
            "triggerName" : "Appliance_4",
            "updatedBy" : 16,
            "enable" : 1,
            "id" : 87,
            "createdBy" : 16,
            "enterpriseId" : 29,
            "name" : "Fan-Test112"
        ], [
            "createdBy" : 16,
            "triggerName" : "Appliance 11",
            "enable" : 1,
            "startTime" : "02:41 PM",
            "enterpriseId" : 29,
            "endTime" : "02:41 PM",
            "triggerAction" : 2,
            "appliances" : [
                [
                    "applianceId" : 11,
                    "targetAction" : 1,
                    "targetAccess" : 1,
                    "targetValue" : 0,
                    "bindingRuleId" : 85,
                    "id" : 11,
                    "applianceName" : "Appliance 11"
                ]
            ],
            "updatedBy" : 0,
            "id" : 85,
            "triggerId" : 11,
            "name" : "RGB"
        ], [
            "createdBy" : 16,
            "triggerName" : "Appliance 11",
            "enable" : 1,
            "startTime" : "10:20 AM",
            "enterpriseId" : 29,
            "endTime" : "10:20 AM",
            "triggerAction" : 1,
            "appliances" : [
                [
                    "targetAccess" : 1,
                    "applianceId" : 11,
                    "id" : 11,
                    "bindingRuleId" : 84,
                    "applianceName" : "Appliance 11",
                    "targetValue" : 0,
                    "targetAction" : 1
                ],
                [
                    "targetAccess" : 1,
                    "applianceId" : 11,
                    "id" : 11,
                    "bindingRuleId" : 84,
                    "applianceName" : "Appliance 11",
                    "targetValue" : 0,
                    "targetAction" : 1
                ]
            ],
            "updatedBy" : 16,
            "id" : 84,
            "triggerId" : 11,
            "name" : "Aaa"
        ], [
            "createdBy" : 16,
            "triggerName" : "Appliance_3",
            "enable" : 1,
            "startTime" : "05:32 PM",
            "enterpriseId" : 29,
            "endTime" : "06:32 PM",
            "triggerAction" : 3,
            "appliances" : [
                [
                    "applianceId" : 88,
                    "targetAction" : 1,
                    "bindingRuleId" : 80,
                    "applianceName" : "Appliance_3",
                    "targetValue" : 1,
                    "targetAccess" : 1,
                    "id" : 88
                ],
                [
                    "applianceId" : 88,
                    "targetAction" : 1,
                    "bindingRuleId" : 80,
                    "applianceName" : "Appliance_3",
                    "targetValue" : 0,
                    "targetAccess" : 1,
                    "id" : 88
                ],
                [
                    "applianceId" : 89,
                    "targetAction" : 2,
                    "bindingRuleId" : 80,
                    "applianceName" : "Appliance_4",
                    "targetValue" : 0,
                    "targetAccess" : 2,
                    "id" : 89
                ],
                [
                    "applianceId" : 88,
                    "targetAction" : 3,
                    "bindingRuleId" : 80,
                    "applianceName" : "Appliance_3",
                    "targetValue" : 0,
                    "targetAccess" : 3,
                    "id" : 88
                ]
            ],
            "updatedBy" : 16,
            "id" : 80,
            "triggerId" : 88,
            "name" : "test1"
        ]]
        arrayAppliancesListInSiri.removeAll()
        for object in array {
            arrayAppliancesListInSiri.append(SiriApplianceDataModel.init(param: JSON.init(object)))
        }
    }
}
