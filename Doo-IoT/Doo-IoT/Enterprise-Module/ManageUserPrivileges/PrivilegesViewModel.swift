//
//  PrivilegesViewModel.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 10/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class PrivilegesViewModel {
    
    var infinityTree: InfinityTree? = nil
    var allSelectionOption = ""
    
    // Pagination work
    var getAvailableElements: Int { return infinityTree?.trees.count ?? 0 }
    
    //================================================
    func callGetSelectedAllDevicesByUserAPI(routingParam: [String: Any], success: @escaping ()->()) {
        API_SERVICES.callAPI(path: .getPrivillegsDevicesByUserIdToEnterprise(routingParam), method: .get) { (parsingResponse) in
            if self.parseAllEnterpriseUsers(parsingResponse){
                success()
            }
        }
    }
    
    func getGroupIds() -> [Int] {
        return self.infinityTree!.trees.map({ (obj) -> Int in
            return (obj.value as? UserPrivilegeDataModel)?.dataId ?? 0
        })
    }
    
    func getGroupDeviceApplienceIds() -> (groupIds:[Int],deviceIds:[Int],applienceIds:[Int]) {
        var arrayGroupIds = [Int]()
        var arrayDevieIds = [Int]()
        var arrayApplieceIds = [Int]()
        self.infinityTree!.trees.forEach { (obj) in
            arrayGroupIds.append((obj.value as? UserPrivilegeDataModel)?.dataId ?? 0)
            obj.children.forEach { (obj2) in
                arrayDevieIds.append((obj2.value as? UserPrivilegeDataModel)?.dataId ?? 0)
                obj2.children.forEach { (obj3) in
                    arrayApplieceIds.append((obj3.value as? UserPrivilegeDataModel)?.dataId ?? 0)
                }
            }
        }
        
        return (arrayGroupIds,arrayDevieIds,arrayApplieceIds)
    }
    
    //=============================================
}

// MARK: User privileges assignment. (Case - .userDetail) & (Case - .selectedUsersToAssign)
extension PrivilegesViewModel {
    func callGetUserSelectedAllDevicesAPI(userId:String = "", routingParam: [String: Any],
                                          success: @escaping ()->(),
                                          failureMessageBlock: @escaping (String) -> (),
                                          internetFailureBlock: @escaping () -> (),
                                          failureInform: @escaping () -> ()) {
        API_SERVICES.callAPI(path: userId.isEmpty ?  .getUserPrivillegsDevicesToEnterprise(routingParam) : .getSelectedUsersPrivillegsOfDevices(userId), method: .get) { (parsingResponse) in
            if self.parseAllEnterpriseUsers(parsingResponse){
                success()
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        } internetFailure: {
            internetFailureBlock()
        } failureInform: {
            failureInform()
        }
    }
    
    func parseAllEnterpriseUsers(_ response: [String: JSON]?) -> Bool {
        guard let payload = response?["payload"]?.arrayValue else {return false}
        configureTreeForEnterpriseUserPrivileges(jsonDataOptions: payload)
        return true
    }
    
    func configureTreeForEnterpriseUserPrivileges(jsonDataOptions:[JSON]) {
        var treeNodes: [UserPrivilegeDataModel] = []
        var allData = jsonDataOptions
        
        
        // Insert all selection option in allData. We are adding json data here, which will be converted to one option later.
        if allData.count > 0 && !allSelectionOption.isEmpty{
            allData.insert(JSON.init(["name":allSelectionOption]), at: 0)
        }
        
        
        // Add parent nodes.
        for data in allData{
            let obj = UserPrivilegeDataModel.init(withJSON: data)
            treeNodes.append(obj)
        }
        
        // childs management.
        let infinityTreeParameters: InfinityTreeParameters = InfinityTreeParameters(showChildsUpToLevel: 0)
        
        // Logic? - Right now seems like switching appliance to device key & adding device key if not exists. We could have passed allData rather than creating this arrayDict...
        var arrayDict = [[String:Any]]()
        for obj in allData.enumerated(){
            if var dict  = obj.element.dictionaryObject{
                let arrayTempDevices = (dict["device"] as? [Any] ?? [])
                var arrayNewCreateDevice = [[String:Any]]()
                for devics in arrayTempDevices{
                    if var dictData = devics as? [String:Any]{
                        dictData.switchKey(fromKey: "appliance", toKey: "device")
                        arrayNewCreateDevice.append(dictData)
                    }
                }
                dict["device"]  = arrayNewCreateDevice
                arrayDict.append(dict)
            }
        }
        
        
        self.infinityTree = InfinityTree.init(jsonValues: arrayDict,
                                              values: treeNodes,
                                              infinityTreeParameters: infinityTreeParameters,
                                              sectionInTableView: 0) { (parent) -> (values: [Any], jsonValues: [[String : Any]]) in
            
            if let jsonDataOptions = (parent["device"] as? [[String: Any]]) {
                var treeNodes: [UserPrivilegeDataModel] = []
                for data in jsonDataOptions {
                    let objModel = UserPrivilegeDataModel.init(withJSON: JSON.init(data))
                    treeNodes.append(objModel)
                }
                return (treeNodes, jsonDataOptions)
            }
            // if nothing to parse
            return ([], [])
        }
    }
}

// MARK: Get Devices list for Groups Module
extension PrivilegesViewModel {
    //=== used for group selection devices
    func callGetSelectedAllDevicesAPI(success: @escaping ()->(),
                                      failureMessageBlock: @escaping (String) -> (),
                                      internetFailureBlock: @escaping () -> (),
                                      failureInform: @escaping () -> ()) {
        API_SERVICES.callAPI(path: .getAllDevicesForGroup, method: .get) { (parsingResponse) in
            if let json = parsingResponse, self.parseAllDeviceForGroup(JSON.init(json)){
                success()
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        } internetFailure: {
            internetFailureBlock()
        } failureInform: {
            failureInform()
        }
    }
    
    func parseAllDeviceForGroup(_ response: JSON?) -> Bool {
        guard let payload = response?["payload"].arrayValue else { return false }
        configureTreeForGroupDevices(jsonDataOptions: payload)
        return true
    }
    
    func configureTreeForGroupDevices(jsonDataOptions:[JSON]) {
        var treeNodes: [DeviceDataModel] = []
        
        
        for data in jsonDataOptions{
            let obj = DeviceDataModel.init(fromGroupSelectionDevice: data)
            treeNodes.append(obj)
        }
        
        // childs management.
        let infinityTreeParameters: InfinityTreeParameters = InfinityTreeParameters(showChildsUpToLevel: 0)
        
        var arrayDict = [[String:Any]]()
        for obj in jsonDataOptions.enumerated(){
            if let dict  = obj.element.dictionaryObject{
                //                dict["device"]  = arrayApplince
                arrayDict.append(dict)
            }
        }
        
        self.infinityTree = InfinityTree.init(jsonValues: arrayDict,
                                              values: treeNodes,
                                              infinityTreeParameters: infinityTreeParameters,
                                              sectionInTableView: 0) { (parent) -> (values: [Any], jsonValues: [[String : Any]]) in
            
            if let jsonDataOptions = (parent["applianceDetails"] as? [[String: Any]]) {
                var treeNodes: [ApplianceDataModel] = []
                for data in jsonDataOptions {
                    treeNodes.append(ApplianceDataModel.init(dict: JSON.init(data)))
                }
                return (treeNodes, jsonDataOptions)
            }
            // if nothing to parse
            return ([], [])
        }
    }
}


// Mark: Helper stuff.
extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let entry = removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
}
