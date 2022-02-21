//
//  SelectDooUserViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 13/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class SelectDooUserViewModel {
    
    var arrayUsers = [DooUser]()
    var selectedUser: DooUser?
    var arrayUsersWithoutSearch = [DooUser]()
    
    // Pagination work
    private var totalElements = 0
    var getAvailableElements: Int { return arrayUsers.count }
    var getTotalElements: Int { return totalElements }
    private let pageSize = 20
    func getPageDict(_ isFromPullToRefresh: Bool) -> [String: Any] {
        // here 1 for requested list
        func getPageNo() -> Int {
            if !isFromPullToRefresh {
                return 0
            } else {
                return getAvailableElements / pageSize
            }
        }
        return ["page": getPageNo(), "size": pageSize]
    }

    func callGetAllEnterpriseUsersAPI(searchText:String,arrayPreSelectedGroups: [DooUser],
                                    param: [String: Any],
                                    successBlock: @escaping ()->(),
                                    failureMessageBlock: @escaping () -> ()) {
        
        API_SERVICES.callAPI( param,path: .getAllEnterpriseUsers(searchText)) { (parsingResponse) in
            if let json = parsingResponse, self.parseAllEnterpriseUsers(json, page: param["page"] as? Int ?? 0, searchText: searchText) {
                self.removePreSelected(arrayUsersPreSelected: arrayPreSelectedGroups)
                successBlock()
            }
        } failureInform: {
            failureMessageBlock()
        }
    }
    
    func parseAllEnterpriseUsers(_ response: [String: JSON], page: Int = 0, searchText: String) -> Bool {
        guard let payload = response["payload"]?.dictionaryValue,
            let users = payload["content"]?.arrayValue,
            let totalElements = payload["pageable"]?.dictionaryValue["totalElements"]?.intValue else { return false }
        self.totalElements = totalElements
        if page == 0 {
            arrayUsers.removeAll()
            if searchText.isEmpty {
                // so clears it when called api without search.
                arrayUsersWithoutSearch.removeAll()
            }
        }
        for user in users {
            arrayUsers.append(DooUser(dict: user))
            if searchText.isEmpty {
                // Without search user's array. So after search we can directly assign to list to show case the list which was loaded before.
                arrayUsersWithoutSearch.append(DooUser.init(dict: user))
            }
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
