//
//  DeviceDetailViewModel.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class DeviceDetailViewModel {
    
    // Sections work....
    enum EnumSection: Int {
        case deviceDetail = 0, appliances
        var index: Int {
            switch self {
            case .deviceDetail: return 0
            case .appliances: return 1
            }
        }
    }
    
    struct FirstSectionData {
        var title = ""
        var value = ""
        var color: UIColor = UIColor.blueSwitch
    }
    var sections = [String]()
    var firstSectionData = [FirstSectionData]()
    var deviceData: DeviceDataModel? = nil
    
    init() {}
    
    // get device detail
    func callGetDeviceDetailFromDeviceIdAPI(deviceID: String, success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        
        API_SERVICES.callAPI(path: .getDeviceDetailFromDeviceId(deviceID), method:.get) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let selfStrong = self, selfStrong.parseDeviceDetail(json){
                success()
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    func parseDeviceDetail(_ response: [String:JSON]) -> Bool {
        guard let device = response["payload"] else { return false }
        deviceData?.update(deviceDetailById: device)
        resetArrayOfSectionAndData()
        loadData()
        return true
    }
    
    func resetArrayOfSectionAndData(){
        sections.removeAll()
        firstSectionData.removeAll()
    }
    
    func loadData() {
        // create sections
        sections = [localizeFor("device_detail")]
        guard let deviceObject = deviceData else {
            return
        }
        guard let status = deviceObject.getEnumStatus else { return }
        firstSectionData.append(FirstSectionData.init(title: localizeFor("status"), value: status.name, color: status.color))
        firstSectionData.append(FirstSectionData.init(title: localizeFor("serial_number"), value: deviceObject.serialNumber))
        if deviceObject.productIsGateway {
            firstSectionData.append(FirstSectionData.init(title: localizeFor("location"), value: deviceObject.location))
        } else {
            firstSectionData.append(FirstSectionData.init(title: localizeFor("gateway"), value: deviceObject.gatewayName))
        }
        if deviceObject.appliances.count != 0 {
                    let str  = deviceObject.appliances.count > 1 ? localizeFor("appliances") : localizeFor("appliance")
        //            sections.append("\(str) (\(deviceObject.appliances.count))")
                    sections.append(str)
                    
                }
    }
    
    // favourite un favourite appliance
    func callApplianceToggleFavouriteAPI(_ param: [String: Any],
                                         successBlock: @escaping (String)->(),
                                         failureMessageBlock: @escaping (String) -> ()) {
        API_SERVICES.callAPI(path: .applianceToggleFavourite(param)) { (parsingResponse) in
            if let json = parsingResponse{
                successBlock(json["message"]?.stringValue ?? "")
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        }
    }
    
    // enable and disable appliance
    func callApplianceToggleEnableAPI(_ param: [String: Any],
                                      successBlock: @escaping ()->(),
                                      failureMessageBlock: @escaping (String) -> ()) {
        
        API_SERVICES.callAPI(path: .applianceToggleEnable(param), method:.put) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let selfStrong = self, selfStrong.parseDeviceDetail(json){
                successBlock()
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        }
    }
    
    // delete appliance
    func callDeleteDeviceAPI(_ param: [String:Any],
                             isGateway:Bool,
                             successBlock: @escaping ()->(),
                             failureMessageBlock: @escaping (String) -> ()) {
        
        API_SERVICES.callAPI(param, path: .deleteDevice, method:.post) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let selfStrong = self, selfStrong.parseDeviceDetail(json){
                successBlock()
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        }
    }
}
