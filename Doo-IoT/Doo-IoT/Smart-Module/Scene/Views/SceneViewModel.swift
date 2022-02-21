//
//  sceneViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 28/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation



class SceneViewModel{
    
    init() {}
    var arraySceneList = [SRSceneDataModel]()
    var isScenesFetched: Bool = false
    
    var isFromSiri: Bool = false
    // Pagination work for Binding Rule
    private var totalElements = 0
    var getAvailableElements: Int { return arraySceneList.count }
    var getTotalElements: Int { return totalElements }
    private var pageSize = 20
    func getPageDict(_ isFromPullToRefresh: Bool) -> [String: Any] {
        // here 1 for requested list
        func getPageNo() -> Int {
            pageSize = isFromSiri ? 1000 : 20
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
        arraySceneList.removeAll { (obj) -> Bool in
            if obj.id == id && totalElements > 0{
                totalElements -= 1
            }
            return obj.id == id
        }
    }

    // ================== Scene List ===================== //
    func callGetSceneListAPI(param:[String:Any], success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .sceneList(param), method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                self.parseScenesList(jsonResponse, page: param["page"] as? Int ?? 1, completion: {isSucceeded in
                    if isSucceeded {
                        success()
                    }else{
                        failureInform()
                    }
                })
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }

    func parseScenesList(_ response: [String: JSON], page:Int, completion: @escaping (Bool)->()) {
        guard let payload = response["payload"]?.dictionaryValue["data"]?.dictionaryValue, let content = payload["content"]?.arrayValue, let totalElements = payload["pager"]?.dictionaryValue["totalRecord"]?.intValue else {
            completion(false)
            return
        }
        debugPrint(content)
        self.totalElements = totalElements
        debugPrint("page passed: \(page)")
        if page == 1 { arraySceneList.removeAll() }
        for objScene in content {
            let obj = SRSceneDataModel.init(param: objScene)
            if isFromSiri == true {
                if obj.viewEditMode == .viewEdit {
                        arraySceneList.append(obj)
                }
            } else {
                arraySceneList.append(SRSceneDataModel.init(param: objScene))
            }
        }
        if isFromSiri == true {
            self.totalElements = arraySceneList.count
        }
        
        shuffleScenesToKnowAboutWhichScenesAddedToSiri(withParsedScenesList: arraySceneList) {
            debugPrint("Done with finding out available scenes!")
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    func shuffleScenesToKnowAboutWhichScenesAddedToSiri(withParsedScenesList scenesList: [SRSceneDataModel],
                                                        completion: @escaping ()->()) {
        
        ShortcutHandler.getAllVoiceShortcuts(withCompletion: { shortcuts, error in
            if let voiceShortcuts = shortcuts {
                for scene in scenesList {
                    if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? SceneExecutionIntent)?.sceneId as? Int == scene.id && ($0.shortcut.intent as? SceneExecutionIntent)?.userId as? Int == APP_USER?.userId}) {
                        scene.isAddedToSiri = true
                        scene.shortcutUUID = shortcutImnt.identifier.uuidString
                    } else {
                        scene.isAddedToSiri = false
                    }
                }
                completion()
            } else {
                if let error = error as NSError? {
                    print(error.debugDescription)
                }
            }
        })
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
        arraySceneList.removeAll()
        for objScene in content {
            arraySceneList.append(SRSceneDataModel.init(param: objScene))
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
        arraySceneList.removeAll()
        for object in array {
            arraySceneList.append(SRSceneDataModel.init(param: JSON.init(object)))
        }
    }
}
