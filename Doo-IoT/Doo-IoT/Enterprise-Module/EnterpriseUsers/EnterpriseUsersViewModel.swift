//
//  EnterpriseUsersViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 06/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class EnterpriseUsersViewModel {
    
    var arrayUsers = [DooUser]()
    var enterpriseId: String?
    
    // Pagination work
    var totalElements = 0
    var getAvailableElements: Int { return arrayUsers.count }
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

    func callGetUsersBelongsToEnterpriseAPI(_ param: [String: Any],
                                            searchingText: String,
                                    success: @escaping ()->(),
                                    unbiasedCompletion: @escaping ()->()) {
        
        var routingParam: [String: Any] = [:]
        if let enterpriseIdStrong = enterpriseId {
            routingParam["enterpriseId"] = enterpriseIdStrong
            routingParam["searchingValue"] = searchingText
        }
        
        API_SERVICES.callAPI(param, path: .getUsersBelongsToEnterprise(routingParam)) { (parsingResponse) in
            if self.parseUsersBelongsToEnterprise(parsingResponse, searchText: searchingText, page: param["page"] as? Int ?? 0){
//                self.removePreSelected(arrayUsersPreSelected: arrayPreSelectedGroups)
                success()
            }
        } failureInform: {
            unbiasedCompletion()
        }
    }
    
    func parseUsersBelongsToEnterprise(_ response: [String: JSON]?, searchText: String, page: Int = 0) -> Bool {
        guard let payload = response?["payload"]?.dictionaryValue,
            let users = payload["content"]?.arrayValue,
            let totalElements = payload["pageable"]?.dictionaryValue["totalElements"]?.intValue else { return false }
        self.totalElements = totalElements
        if page == 0 {
            arrayUsers.removeAll()
        }
        
        for user in users {
            arrayUsers.append(DooUser(dict: user))
        }
        shiftAcceptedDisableUserToBottom()
        return true
    }

    private func removePreSelected(arrayUsersPreSelected: [DooUser]) {
        //remove alerady selected users
        arrayUsers.removeAll { (user) -> Bool in
            return arrayUsersPreSelected.contains(where: { $0.id == user.id })
        }
    }
    
    func shiftAcceptedDisableUserToBottom() {
        for i in stride(from: arrayUsers.count - 1, through: 0, by: -1) {
            print("test index : \(i)")
            if let status = arrayUsers[i].getEnumInvitationStatus {
                if status == .accepted, !arrayUsers[i].enable {
                    shiftUserToBottom(index: i)
                }
            }
        }
    }

    func shiftUserToBottom(index: Int) {
        arrayUsers.append(arrayUsers.remove(at: index))
    }
}
