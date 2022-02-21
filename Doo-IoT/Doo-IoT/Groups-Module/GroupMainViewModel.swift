//
//  GroupMainViewModel.swift
//  Doo-IoT
//
//  Created by Akash on 26/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class GroupMainViewModel {
    enum EnumSectionUserInfoRow: Int { case groupTabs = 0, newDeviceAdd, other }
    var groups = [GroupDataModel]()
    init() {}
}

//======================== Group List ======================
extension GroupMainViewModel{
    func callGetAllGroupsAPI( successBlock: @escaping ()->(),
                              failureMessageBlock: @escaping (String) -> (),
                              internetFailureBlock: @escaping () -> (),
                              failureInform: @escaping () -> ()) {
        
        API_SERVICES.callAPI(path: .getAllGroups, method:.get) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let selfStrong = self, selfStrong.parseAllGroups(json){
                successBlock()
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        } internetFailure: {
            internetFailureBlock()
        } failureInform: {
            failureInform()
        }
    }
    
    func parseAllGroups(_ response: [String:JSON]) -> Bool {
        groups.removeAll()
        
        guard let arrayGroups = response["payload"]?.array else { return false }
        for group in arrayGroups {
            groups.append(GroupDataModel.init(withGroupList: group))
        }
        return true
    }
}

//============== Group ---> ON OFF All Device Applience ====================
extension GroupMainViewModel{
    func callGroupAllDeviceONOFFAPI(
        param: [String: Any],
        successBlock: @escaping (String)->(),
        failureMessageBlock: @escaping (String) -> ()) {
        
        let jsonDict = JSON.init(param)
        guard let groupId = jsonDict.dictionaryValue["groupId"]?.intValue, let action = jsonDict.dictionaryValue["action"]?.intValue else {
            return
        }
        API_SERVICES.callAPI(path: .groupAllDeviceApplienceONOFF(groupId, action), method:.put) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let selfStrong = self, selfStrong.parseGroupAllDeviceONOFF(json){
                successBlock(json["message"]?.stringValue ?? "")
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        }
    }
    
    func parseGroupAllDeviceONOFF(_ response: [String:JSON]) -> Bool {
        guard let _ = response["payload"] else { return false }
        return true
    }
}
