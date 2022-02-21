//
//  SelectUsersForAssignPrivilegesViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 14/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
class SelectUsersForAssignPrivilegesViewModel {
    
    var arrayUsers = [DooUser]()
    var arraySelectedUsers = [DooUser]()
    
    var isHeaderShow: Bool {
        return !arraySelectedUsers.count.isZero()
    }
    
    // Pagination work
    var totalElements = 0
    var getAvailableElements: Int { return arrayUsers.count }
    var getTotalElements: Int { return totalElements }
    private let pageSize = 10
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
    
    func checkUncheckMainList(index: Int) {
        arrayUsers[index].selected.toggle()
        let selectedUser = arrayUsers[index]
        if selectedUser.selected {
            arraySelectedUsers.append(selectedUser)
        } else {
            arraySelectedUsers.removeAll { (user) -> Bool in
                user.id == selectedUser.id
            }
        }
    }
    
    func removeSelectedUser(index: Int) -> Int {
        let removedUser = arraySelectedUsers.remove(at: index)
        if let userIndex = arrayUsers.firstIndex (where: { (user) -> Bool in
            user.id == removedUser.id
        }) {
            arrayUsers[userIndex].selected = false
            return userIndex
        }
        return 0
    }
    
    // ||=============================== Get Privilleg Users of Enterprise ========================||
    func callGetPrivillegsUsersBelongsToEnterpriseAPI(_ param: [String: Any],
                                                      successBlock: @escaping ()->(),
                                                      failureMessageBlock: @escaping (String) -> ()) {
        API_SERVICES.callAPI(param, path: .getUsersPrivillegsBelongsToEnterprise, method: .get) { (parsingResponse) in
            if let jsonResponse = parsingResponse, self.parseUsersBelongsToEnterprise(jsonResponse, page: param["page"] as? Int ?? 0){
                successBlock()
            }
        }
    }
    
    func parseUsersBelongsToEnterprise(_ response: [String:JSON],
                                       page: Int = 0) -> Bool {
        
        guard let payload = response["payload"]?.dictionaryValue,
              let users = payload["content"]?.arrayValue,
              let totalElements = payload["pageable"]?.dictionaryValue["totalElements"]?.intValue else { return false }
        // self.totalElements = totalElements
        self.totalElements = totalElements // assign total elements received from response.
        if page == 0 {
            arrayUsers.removeAll()
        }
        for user in users {
            arrayUsers.append(DooUser(dict: user))
        }
        return true
    }
    
    // ||=============================== Get ALl Enterprise Users ========================||
    func getEnterpriseUsersAPI(searchText:String,
                                      param: [String: Any],
                                      successBlock: @escaping ()->(),
                                      failureMessageBlock: @escaping (String) -> ()) {
        
        guard let user = APP_USER, let selectedEnterprise = user.selectedEnterprise else { return }
        let urlQueryParams = ["enterpriseId": String(selectedEnterprise.id),
                              "searchingValue": searchText]
        API_SERVICES.callAPI(param, path: .getUsersBelongsToEnterprise(urlQueryParams)) { (parsingResponse) in
            if let jsonResponse = parsingResponse, self.parseAllEnterpriseUsers(jsonResponse,
                                                                                searchText: searchText,
                                                                                page: param["page"] as? Int ?? 0){
                successBlock()
            }
        }
    }
    
    func parseAllEnterpriseUsers(_ response: [String:JSON],
                                 searchText: String,
                                 page: Int = 0) -> Bool {
        
        guard let payload = response["payload"]?.dictionaryValue,
              let users = payload["content"]?.arrayValue,
              let totalElements = payload["pageable"]?.dictionaryValue["totalElements"]?.intValue else { return false }
        self.totalElements = totalElements
        if page == 0 {
            arrayUsers.removeAll()
        }
        for user in users {
            arrayUsers.append(DooUser(dict: user))
        }
        return true
    }
    
    private func removePreSelected(arrayUsersPreSelected: [DooUser]) {
        //remove alerady selected users
        arrayUsers.removeAll { (user) -> Bool in
            return arrayUsersPreSelected.contains(where: { $0.id == user.id })
        }
    }
}


// MARK: Dummy Data.
extension SelectUsersForAssignPrivilegesViewModel {
    func loadData() {
        arrayUsers = [
            DooUser(id: 1, firstName: "Selena", lastName: "Stanley", mobile: "", email: "stanley_sel@gmail.com", image: "user1", invitationStatus: 1),
            DooUser(id: 2, firstName: "Josheph", lastName: "Turner", mobile: "9090909090", email: "", image: "user2", invitationStatus: 1),
            DooUser(id: 3, firstName: "", lastName: "", mobile: "", email: "william_geourgedesign20@gmail.com", image: "user3", invitationStatus: 1),
            DooUser(id: 4, firstName: "Stan", lastName: "Kim", mobile: "", email: "kimstan526@gmail.com", image: "user4", invitationStatus: 2),
            DooUser(id: 5, firstName: "Lee", lastName: "Gen", mobile: "", email: "genlee@gmail.com", image: "user5", invitationStatus: 1),
            DooUser(id: 6, firstName: "Deny", lastName: "Will", mobile: "", email: "deny_will@gmail.com", image: "user6", invitationStatus: 1),
            DooUser(id: 7, firstName: "Stan", lastName: "Kim", mobile: "", email: "kimstan@gmail.com", image: "user7", invitationStatus: 1),
            DooUser(id: 8, firstName: "Kailey", lastName: "Stark", mobile: "8989898989", email: "", image: "user8", invitationStatus: 0),
            DooUser(id: 9, firstName: "William", lastName: "Shein", mobile: "", email: "william.shein23@gmail.com", image: "user9", invitationStatus: 0),
            DooUser(id: 10, firstName: "William2", lastName: "Shein", mobile: "", email: "william.shein232@gmail.com", image: "user10", invitationStatus: 0),
        ]
    }
}
