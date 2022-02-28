//
//  EnterpriseUserDetailViewModel.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 11/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class EnterpriseUserDetailViewModel {
    enum EnumSection: Int {
        case userDetail, privileges
        var index: Int {
            switch self {
            case .userDetail: return 0
            case .privileges: return 1
            }
        }
    }
    struct EnterpriseUserDetailField {
        var title = ""
        var value = ""
    }
    
    var arrayOfUserDetailFields = [EnterpriseUserDetailField]()
    var sections = [String]()

    func loadData(enterpriseUser: DooUser, privilegesCount: Int = 0) {
        arrayOfUserDetailFields = [
            EnterpriseUserDetailField(title: localizeFor("email_address"), value: enterpriseUser.email),
            EnterpriseUserDetailField(title: localizeFor("mobile"), value: enterpriseUser.mobile),
        ]
        
        // create sections
        sections = [localizeFor("user_detail_section")]
    }
    
    func createPrivillgesSection(_ enterpriseUser: DooUser){
        if let rowsCount = enterpriseUser.privilegesTree?.getNumberOfRows(), rowsCount != 0 {
            sections.append("\(localizeFor("privileges_section")) (\(rowsCount))")
        }
    }
}
