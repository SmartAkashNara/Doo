//
//  ReceivedInvitationsViewModel.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 13/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class ReceivedInvitationsViewModel {
    
    var receivedInvitations: [ReceivedInvitationDataModel] = []
    var receivedInvitationsFiltered: [Date : [ReceivedInvitationDataModel]] = [:]
    var sortedSections: [Date] = []
    
    // Pagination work
    private var totalElements = 0
    var getAvailableElements: Int { return receivedInvitations.count }
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
    
    func filterOutSectionsBasedOnTime() {
        for index in 0..<receivedInvitations.count {
            var invitation = receivedInvitations[index]
            let date = invitation.invitationDate.getDateUsingTimestamp()
            invitation.setReceivedDate(updatedDate: date)
            receivedInvitations[index] = invitation
        }
        
        let sortedResults = receivedInvitations.sorted(by: {
            $0.identifierDate.compare($1.identifierDate) == .orderedDescending
        })
        
        self.receivedInvitationsFiltered = sortedResults.daySorted
        self.sortedSections = self.receivedInvitationsFiltered.keys.sorted(by: {
            $0.compare($1) == .orderedDescending
        })
    }
    
    // Get Invitation List
    //  ||=======================================================||
    func callGetReceivedInvitations(_ param: [String: Any],
                                    mockIt: Int = 0,
                                    successBlock: @escaping ()->(),
                                    failureMessageBlock: @escaping (String) -> (),
                                    internetFailure: @escaping ()->()) {
        
        
        API_SERVICES.callAPI(path: .enterpriseReceivedInvitations) { (parsingResponse) in
            guard let response = parsingResponse else { return }
            debugPrint("Received Invitation",response)
            if self.parseInvitations(response,page: param["page"] as? Int ?? 0){
                successBlock()
            }
        } failure: { msg in
            failureMessageBlock(msg ?? "")
        } internetFailure: {
            internetFailure()
        }
    }
    
    func parseInvitations(_ response: [String:JSON], page:Int) -> Bool {
        guard let payload = response["payload"]?.dictionaryValue,
              let invitations = payload["content"]?.arrayValue,
              let totalElements = payload["pageable"]?.dictionaryValue["totalElements"]?.intValue else { return false }
        
        self.totalElements = totalElements
        if page == 0{
            self.receivedInvitations.removeAll()
        }
        
        for invitation in invitations {
            let enterpriseInvitation = ReceivedInvitationDataModel.init(dict: invitation)
            self.receivedInvitations.append(enterpriseInvitation)
        }
        return true
    }
    
    // accept and Reject Invitations
    //  ||=======================================================||
    func callAcceptRejectInvitation(_ param: [String: Any],
                                    mockIt: Int = 0,
                                    successBlock: @escaping (String)->(),
                                    failureMessageBlock: @escaping (String) -> ()) {
        
        API_SERVICES.callAPI(path: .acceptRejectReceivedInvitaiton(param), method:.put) { (parsingResponse) in
            guard let response = parsingResponse else { return }
            if let message = self.parseAcceptRejectInvitaion(response){
                successBlock(message)
            }
        }
    }
    
    func parseAcceptRejectInvitaion(_ response: [String:JSON]) -> String? {
        guard let payload = response["payload"]?.dictionaryValue,let message = payload["message"]?.stringValue else {return nil}
        return message
    }
    
    //  ||=======================================================||
    func callGetEnterprises(_ param: [String: Any],
                            mockIt: Int = 0,
                            successBlock: @escaping ()->(),
                            failureMessageBlock: @escaping (String) -> ()) {
        
        
        API_SERVICES.callAPI(param, path: .getEnterprises) { (parsingResponse) in
            guard let response = parsingResponse else { return }
            if self.parseEnterprises(response) {
                successBlock()
            }
        }
    }
    
    func parseEnterprises(_ response: [String:JSON]) -> Bool {
        guard let user = APP_USER else {return false}
        if let enterprises = response["payload"]?.dictionary?["content"]?.arrayValue, enterprises.count != 0{
            // adding enterprise to the list and make it default selected.
            let enterprise = EnterpriseModel.init(dict: enterprises[0])
            ENTERPRISE_LIST.append(enterprise)
            user.selectedEnterprise = enterprise
            UserManager.saveUser() // save update
            return true
        }
        return false
    }
}

