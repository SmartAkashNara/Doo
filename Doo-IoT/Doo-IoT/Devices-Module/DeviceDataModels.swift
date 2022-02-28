//
//  DeviceDataModels.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 08/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
class DeviceDataModel {
    
    enum EnumOnlineOFFLineStatus: Int {
        case offline = 0, online
        var name: String {
            
            switch self {
            case .offline: return localizeFor("offline")
            case .online: return localizeFor("online")
            }
        }
        var color: UIColor {
            switch self {
            case .offline: return UIColor.textFieldErrorColor
            case .online: return UIColor.greenInvited
            }
        }
    }
    
    //get device detail response keys
    var deviceName = ""
    var enable = false
    var productId = ""
    var productImage = ""
    var productName = ""
    var productType = ""
    var productTypeCode = 0
    var productTypeImage = ""
    var productTypeName = ""
    var serialNumber = ""
    
    var enterpriseId = ""
    var enterpriseDeviceId = ""
    var location = ""
    var appliances: [ApplianceDataModel] = []
    var deviceStatus = 0  // online offline status
    var installationDate = 0
    var lat: Double = 0
    var long: Double = 0
    var gatewayName = ""
    var deviceCount = 0
    
    init(fromGroupSelectionDevice dict: JSON) {
        serialNumber = dict["serialNumber"].stringValue
        deviceStatus = dict["deviceStatus"].intValue
        gatewayName = dict["gateway"].stringValue
        productType = dict["deviceTypeName"].stringValue
        deviceName = dict["deviceName"].stringValue
        enterpriseDeviceId = dict["enterpriseDeviceId"].stringValue
        installationDate = dict["installationDate"].intValue
        enterpriseId = dict["enterpriseId"].stringValue
        
        appliances.removeAll()
        if let arrayApplience = dict["applianceDetails"].array{
            parseAppliances(fromGroupMain: arrayApplience)
        }
    }

    var productIsGateway: Bool {
        return productTypeCode == 1
    }
    
    var getInstallationDate: String {
        guard !installationDate.isZero() else { return "" }
        return installationDate.getDateStringByMSecsToSecs(format: .ddSpaceMMspaceYYYY)
    }
    var getEnumStatus: EnumOnlineOFFLineStatus? {
        return EnumOnlineOFFLineStatus(rawValue: deviceStatus)
    }
    
    var isMore = false
    var online: Bool = false
    var applienceEndpoint = 0

    init(dict: JSON) {
        deviceName = dict["deviceName"].stringValue
        enable = dict["enable"].boolValue
        productId = dict["productId"].stringValue
        productImage = dict["productImage"].stringValue
        productType = dict["productType"].stringValue
        productTypeCode = dict["productTypeCode"].intValue
        productTypeImage = dict["productTypeImage"].stringValue
        productTypeName = dict["productTypeName"].stringValue
        serialNumber = dict["serialNumber"].stringValue
    }

    init(fromGroupdDetail dict: JSON) {
        deviceName = dict["name"].stringValue
        
        if let deviceId = dict["deviceId"].string{
            productId = deviceId
        }else if let applianceId = dict["applianceId"].string{
            productId = applianceId
        }

        appliances.removeAll()
        if let arrayApplience = dict["appliance"].array{
            parseAppliances(fromGroupMain: arrayApplience)
        }
    }
    
    var macAddress = ""
    init(fromGroupMain dict: JSON) {
//        deviceStatus = dict["onOffStatus"].intValue // key not coming while fetching group detail
        deviceName = dict["name"].stringValue
        macAddress = dict["macAddress"].stringValue
        if let deviceId = dict["deviceId"].int{
            productId = String(deviceId)
        }else if let applianceId = dict["applianceId"].string{
            productId = applianceId
        }
        
        appliances.removeAll()
        if let arrayApplience = dict["appliance"].array{
            parseAppliances(fromGroupMain: arrayApplience)
        }
    }

    func parseAppliances(fromGroupMain arrayAppliances: [JSON]) {
        appliances.removeAll()
        arrayAppliances.forEach { (appliance) in
            appliances.append(ApplianceDataModel(fromGroupMain: appliance))
        }
    }

    func update(deviceDetailById: JSON) {
        macAddress = deviceDetailById["macAddress"].stringValue
        enterpriseDeviceId = deviceDetailById["enterpriseDeviceId"].stringValue
        enterpriseId = deviceDetailById["enterpriseId"].stringValue
        deviceName = deviceDetailById["deviceName"].stringValue
        deviceStatus = deviceDetailById["deviceStatus"].boolValue ? 1 : 0
        location = deviceDetailById["location"].stringValue
        serialNumber = deviceDetailById["serialNumber"].stringValue
        installationDate = deviceDetailById["installationDate"].intValue
        productTypeName = deviceDetailById["deviceTypeName"].stringValue
        lat = deviceDetailById["latitude"].doubleValue
        long = deviceDetailById["longitude"].doubleValue
        productTypeCode = deviceDetailById["gateway"].boolValue ? 1 : 0
        gatewayName = deviceDetailById["gatewayName"].stringValue
        if productTypeCode == 0{ //  here we want to show applience list when devie is not gateway
            parseAppliances(deviceDetailById["applianceDetails"].arrayValue)
        }
    }
    
    func update(addedDevice: JSON) {
        enterpriseDeviceId = addedDevice["deviceId"].stringValue
        deviceCount = addedDevice["deviceCount"].intValue
        productTypeCode = addedDevice["gateway"].boolValue ? 1 : 0
        productImage = addedDevice["image"].stringValue
        productTypeName = addedDevice["name"].stringValue
        productId = addedDevice["productTypeId"].stringValue
    }
    
    init(deviceListDict: JSON) {
        macAddress = deviceListDict["macAddress"].stringValue
        enterpriseDeviceId = deviceListDict["enterpriseDeviceId"].stringValue
        enterpriseId = deviceListDict["enterpriseId"].stringValue
        deviceName = deviceListDict["deviceName"].stringValue
        deviceCount = deviceListDict["deviceCount"].intValue
        deviceStatus = deviceListDict["deviceStatus"].intValue
        productTypeCode = deviceListDict["gateway"].boolValue ? 1 : 0
        applienceEndpoint = deviceListDict["endpoints"].intValue
    }

    func parseAppliances(_ arrayAppliances: [JSON]) {
        appliances.removeAll()
        arrayAppliances.forEach { (appliance) in
            appliances.append(ApplianceDataModel(dict: appliance))
        }
    }
}
