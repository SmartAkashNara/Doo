//
//  SelectEnterpriseGroupsViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 11/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class SelectEnterpriseGroupsViewModel {
    
    var arraySelectedGroups = [EnterpriseGroup]()
    var arrayGroups = [EnterpriseGroup]()
    
    func callGetEnterpriseGroupsAPI(arrayPreSelectedGroups: [EnterpriseGroup],
                                    param: [String: Any],
                                    isUpdate: Bool,
                                    enterpriseID: String,
                                    success: @escaping ()->(),
                                    failure: @escaping (String?)->(),
                                    internetFailure: @escaping ()->(),
                                    failureInform: @escaping ()->()) {
        
        API_SERVICES.callAPI(param, path: .getGroups(isUpdate, enterpriseID)) { (parsingResponse) in
            if self.parseEnterpriseGroups(parsingResponse){
                self.setGroupsSelectedAsPerEditModeOfEnterprise(arrayPreSelectedGroups: arrayPreSelectedGroups)
                success()
            }
        }  failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    func parseEnterpriseGroups(_ response: [String: JSON]?) -> Bool {
        guard let payload = response?["payload"]?.dictionary else { return false }
        arrayGroups.removeAll()
        
        if let arrayPlatformGroup = payload["platformGroup"]?.arrayValue{
            for group in arrayPlatformGroup {
                arrayGroups.append(EnterpriseGroup(dict: group, flow: .groupListApi))
            }
        }
        
        if let arraySelectedGroup = payload["selectedGroup"]?.arrayValue{
            for group in arraySelectedGroup {
                arrayGroups.append(EnterpriseGroup(dict: group, flow: .groupListApi))
            }
        }
        return true
    }
    
    // While edit enterprise, there would have been preselected groups, make those selected and add in selected array, add others in normal array.
    func setGroupsSelectedAsPerEditModeOfEnterprise(arrayPreSelectedGroups: [EnterpriseGroup]) {
        arraySelectedGroups.removeAll()
        arrayPreSelectedGroups.forEach { (preSelectedGroup) in
            
            if let matchGroupIndex = arrayGroups.firstIndex ( where: { (group) -> Bool in
                group.id == preSelectedGroup.id
            }) {
                arrayGroups[matchGroupIndex].checked = true
                arrayGroups[matchGroupIndex].groupOfAddTime = preSelectedGroup.groupOfAddTime
            }else{
                // Add additional (Manually created) groups
                preSelectedGroup.checked = true // as its selected before, make it group
                arrayGroups.append(preSelectedGroup)
            }
            arraySelectedGroups.append(preSelectedGroup)
        }
    }
    
    func addPreservedNewlyAddedGroupsTillAddEnterpriseDeinits(arrayManuallyAdded:[EnterpriseGroup]){
        let names = arrayGroups.map({$0.name})
        arrayManuallyAdded.forEach { (obj) in
            if !names.contains(obj.name){
                arrayGroups.append(obj)
            }
        }
    }
    
    func checkUncheckMainList(index: Int) {
        arrayGroups[index].checked.toggle()
        let selectedGroup = arrayGroups[index]
        if selectedGroup.checked {
            arraySelectedGroups.append(selectedGroup)
        } else {
            arraySelectedGroups.removeAll { (group) -> Bool in
                group.id == selectedGroup.id
            }
        }
    }
    
    func removeSelectedGroup(index: Int, isManuallyAddedGroup:Bool=false) -> Int {
        let removedGroup = arraySelectedGroups.remove(at: index)
        if let groupIndex = arrayGroups.firstIndex (where: { (group) -> Bool in
            isManuallyAddedGroup ? group.name == removedGroup.name : group.id == removedGroup.id
        }) {
            arrayGroups[groupIndex].checked = false
            return groupIndex
        }
        return 0
    }
    
    func selectedGroupLastIndexPath() -> IndexPath? {
        if arraySelectedGroups.count.isZero() {
            return nil
        } else {
            return IndexPath(row: arraySelectedGroups.count - 1, section: 0)
        }
    }
}
