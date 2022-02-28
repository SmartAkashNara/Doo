//
//  AddDeviceViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 18/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class AddDeviceViewModel {
    enum ErrorState { case serialNumber, deviceName, deviceType, location, gateway, none }
    
    var gateways: [DooBottomPopupGenericDataModel] = []
    var selectedGateway: DooBottomPopupGenericDataModel?
    var deviceData: DeviceDataModel!
    
    func validateFields(serialNumber: String?, deviceName: String?, deviceType: String?, location: String?, gateway: String?) -> (state:ErrorState, errorMessage:String){
        if InputValidator.checkEmpty(value: serialNumber){
            return (.serialNumber , localizeFor("serial_number_is_required"))
        }
        if InputValidator.checkEmpty(value: deviceName){
            return (.deviceName , localizeFor("device_name_is_required"))
        }
        if !InputValidator.isDeviceNameLength(deviceName){
            return (.deviceName , localizeFor("device_name_2_to_40"))
        }
        if !InputValidator.isDeviceName(deviceName){
            return (.deviceName , localizeFor("plz_valid_device_name"))
        }
        if InputValidator.checkEmpty(value: deviceType){
            return (.deviceType , localizeFor("device_type_is_required"))
        }
        if deviceData.productIsGateway {
            if InputValidator.checkEmpty(value: location){
                return (.location , localizeFor("location_is_required"))
            }
        } else {
            if InputValidator.checkEmpty(value: gateway){
                return (.gateway , localizeFor("gateway_is_required"))
            }
        }
        return (.none ,"")
    }
    
    func callAddDeviceAPI(param: [String: Any],
                          success: @escaping ()->(),
                          failure: @escaping (String?)->()) {
        API_SERVICES.callAPI(param, path: .addDevice) { (parsingResponse) in
            if self.parseDevice(parsingResponse) {
                success()
            }
        } failure: { msg in
            failure(msg)
        }
    }
    
    func parseDevice(_ response: [String: JSON]?) -> Bool {
        guard let device = response?["payload"]?.dictionaryValue["data"] else { return false }
        deviceData.update(addedDevice: device)
        return true
    }
    
    func callGetGatewayListAPI() {
        API_SERVICES.callAPI(path: .getGatewayList, method: .get) { (parsingResponse) in
            guard let arrayGateway = parsingResponse?["payload"]?.arrayValue else { return }
            self.gateways.removeAll()
            for gateway in arrayGateway {
                if let id = gateway["enterpriseDeviceId"].int, id > 0, let name = gateway["deviceName"].string, !name.isEmpty {
                    self.gateways.append(DooBottomPopupGenericDataModel(dataId: "\(id)", dataValue: name))
                }
            }
        }
    }
    
    /*
     func callGetGatewayListAPI() {
     let param: [String:Any] = [
     "criteria": [
     ["column": "productTypeId",
     "operator": "=",
     "values": [1] // here we have passs for gatways list so passed 1
     ]],
     "sort": ["column": "productTypeId",
     "sortType": "asc"],
     ] + ["page":"0","size":"20"]
     
     API_SERVICES.callAPI(param, path: .getDeviceListByType(nil)) { (parsingResponse) in
     guard let arrayGateway = parsingResponse?["payload"]?.dictionaryValue["content"]?.arrayValue else { return }
     self.gateways.removeAll()
     for gateway in arrayGateway {
     if let id = gateway["enterpriseDeviceId"].int, id > 0, let name = gateway["deviceName"].string, !name.isEmpty {
     self.gateways.append(DooBottomPopupGenericDataModel(dataId: "\(id)", dataValue: name))
     }
     }
     }
     }*/
}
