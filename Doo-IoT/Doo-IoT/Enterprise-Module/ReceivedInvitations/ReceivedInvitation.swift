//
//  ReceivedInvitation.swift
//  Doo-IoT
//
//  Created by Akash on 24/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

struct ReceivedInvitationDataModel: DayCategorizable {
    var id: String = ""
    var name: String = ""
    var enterpriseId: String = ""
    var invitationDate: Int = 0
    var identifierDate: Date = Date()
    var invitationTime: String = ""
    var location: String = ""
    
    init(dict: JSON) {
        id = dict["id"].stringValue
        name = dict["enterpriseName"].stringValue
        enterpriseId = dict["enterpriseId"].stringValue
        invitationDate = Int(dict["invitationDate"].intValue.msToSeconds)
        let time = Int(dict["invitationTime"].intValue.msToSeconds)
        if time > 0 {
            invitationTime = time.getDateUsingTimestamp().getDateInString(withFormat: .timeWithAMPM)
        }
        location = dict["location"].stringValue
    }
    
    // Personal use of received invitations screen
    mutating func setReceivedDate(updatedDate: Date) {
        self.identifierDate = updatedDate
    }
}
