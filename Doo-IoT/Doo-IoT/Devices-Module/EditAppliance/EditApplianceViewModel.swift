//
//  EditApplianceViewModel.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class EditApplianceViewModel {
    enum ErrorState { case applianceName, applianceType, none }
    
    var applianceTypes: [DooBottomPopupGenericDataModel] = []
    var selectedApplianceType: DooBottomPopupGenericDataModel?
    var applianceData: ApplianceDataModel!
    
    func validateFields(applianceName: String?, applianceType: String?) -> (state:ErrorState, errorMessage:String){
        if InputValidator.checkEmpty(value: applianceName){
            return (.applianceName , localizeFor("appliance_name_is_required"))
        }
        if !InputValidator.isApplianceNameLength(applianceName){
            return (.applianceName , localizeFor("appliance_name_2_to_40"))
        }
        if !InputValidator.isApplianceName(applianceName){
            return (.applianceName , localizeFor("plz_valid_appliance_name"))
        }
        if InputValidator.checkEmpty(value: applianceType){
            return (.applianceType , localizeFor("appliance_type_is_required"))
        }
        return (.none ,"")
    }
    
    // Get ApplienceType List
    func callGetApplianceTypeListAPI(_ param: [String: Any],
                                     successBlock: @escaping ()->(),
                                     failureMessageBlock: @escaping (String) -> ()) {
        
        API_SERVICES.callAPI(path: .getApplianceTypeList, method:.get) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let selfStrong = self, selfStrong.parseApplianceTypeList(json){
                successBlock()
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        }
    }
    
    func parseApplianceTypeList(_ response: [String:JSON]) -> Bool {
        guard let arrayApplianceTypes = response["payload"]?.array else { return false }
        for applianceType in arrayApplianceTypes {
            applianceTypes.append(
                DooBottomPopupGenericDataModel(dataId: applianceType["id"].stringValue,
                                               dataValue: applianceType["name"].stringValue)
            )
        }
        return true
    }
    
    // Update appliance
    func callUpdateApplianceAPI(_ param: [String: Any],
                                successBlock: @escaping ()->(),
                                failureMessageBlock: @escaping (String) -> ()) {
        
        
        API_SERVICES.callAPI(param, path: .updateAppliance) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let selfStrong = self, selfStrong.parseAppliance(json){
                successBlock()
            }
        } failure: { (msg) in
            failureMessageBlock(msg ?? "")
        }
    }
    
    func parseAppliance(_ response: [String:JSON]) -> Bool {
        guard let arrayAppliances = response["payload"]?["applianceDetails"].array,
              let indexMached = arrayAppliances.firstIndex(where: {$0["id"].stringValue == applianceData.id }) else { return false }
        applianceData.update(dict: arrayAppliances[indexMached])
        return true
    }
    
}
