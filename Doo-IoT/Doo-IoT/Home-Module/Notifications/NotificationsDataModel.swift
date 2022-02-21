//
//  NotificationsDataModel.swift
//  Doo-IoT
//
//  Created by Shraddha on 24/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class NotificationsDataModel {
    
    var id: Int = 0
    var title: String = ""
    var receivedDate: String = ""
    var descriptionString: String = ""
    var descriptionHtml: NSAttributedString = NSAttributedString.init(string: "")
    
    init() {}
    
    init(id: Int, title: String, receivedDate: String, descriptionString: String) {
        self.id = id
        self.title = title
        self.receivedDate = receivedDate
        self.descriptionString = descriptionString
        self.descriptionHtml = self.descriptionString.htmlToAttributedString ?? NSAttributedString.init(string: "")
    }
}
