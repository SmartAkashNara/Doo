//
//  EnterpriseDetailViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 08/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class EnterpriseDetailViewModel {
    enum EnumSection: Int {
        case enterpriseDetail, groups
        var index: Int {
            switch self {
            case .enterpriseDetail: return 0
            case .groups: return 1
            }
        }
    }
    struct EnterpriseDetailField {
        var title = ""
        var value = ""
    }
    var arrayEnterPriceDetailFields = [EnterpriseDetailField]()
    var sections = [String]()

    func loadData(enterpriseDetail: EnterpriseModel) {
        arrayEnterPriceDetailFields = [
            EnterpriseDetailField(title: localizeFor("type_of_enterprise"), value: enterpriseDetail.enterpriseTypeName),
            EnterpriseDetailField(title: localizeFor("location"), value: enterpriseDetail.location),
        ]
        sections.removeAll()
        sections = [localizeFor("enterprise_detail_menu")]
//        if !enterpriseDetail.groups.count.isZero() {
            sections.append("\(localizeFor("groups"))(\(enterpriseDetail.groups.count))")
//        }
    }
}
