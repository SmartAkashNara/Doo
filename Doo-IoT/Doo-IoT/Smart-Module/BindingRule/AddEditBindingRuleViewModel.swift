//
//  AddEditBindingRuleViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 22/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
class AddEditBindingRuleViewModel {
    
    // Action handler
    var currentSelectedAction: EnumTriggerAction? = nil
    var listOfActions: [DooBottomPopupGenericDataModel] = []
    
    // Condition handler
    var currentSelectedCondition: SRBindingRuleDataModel.EnumConditionAction? = nil
    var listOfCondition: [DooBottomPopupGenericDataModel] = []
    
    init() {
        preparedActionsArray()
        preparedConditionsArray()
    }
    
    func preparedActionsArray(){
        listOfActions.removeAll()
        listOfActions.append(DooBottomPopupGenericDataModel.init(dataId: "1", dataValue: "ON"))
        listOfActions.append(DooBottomPopupGenericDataModel.init(dataId: "2", dataValue: "OFF"))
        listOfActions.append(DooBottomPopupGenericDataModel.init(dataId: "3", dataValue: "COMPARE"))
    }
    func preparedConditionsArray(){
        listOfCondition.removeAll()
        listOfCondition.append(DooBottomPopupGenericDataModel.init(dataId: "0", dataValue: "<  Less than"))
        listOfCondition.append(DooBottomPopupGenericDataModel.init(dataId: "1", dataValue: "=  Equal to"))
        listOfCondition.append(DooBottomPopupGenericDataModel.init(dataId: "2", dataValue: ">  Greater than"))
    }
}

extension AddEditBindingRuleViewModel{
    //============================ Add Binding rule  ============================
    func callAddBindingRuleAPI(param:[String:Any], success: @escaping (String, SRBindingRuleDataModel?)->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(param, path: .addBindingRule) { [weak self] (parsingResponse)  in
            if let jsonResponse = parsingResponse{
                if let selfStrong = self, let modelObject = selfStrong.parseAddUpdateBindingRule(jsonResponse){
                    success(jsonResponse["message"]?.stringValue ?? "", modelObject)
                }
            }
            debugPrint("response: \(String(describing: parsingResponse))")
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    //============================ Update edit Binding rule  ============================
    func callUpdateBindingRuleAPI(param:[String:Any], success: @escaping (String, SRBindingRuleDataModel?)->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(param, path: .updateBindingRule) { [weak self] (parsingResponse)  in
            if let jsonResponse = parsingResponse{
                if let selfStrong = self, let modelObject = selfStrong.parseAddUpdateBindingRule(jsonResponse){
                    success(jsonResponse["message"]?.stringValue ?? "", modelObject)
                }
            }
            debugPrint("response: \(String(describing: parsingResponse))")
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    func parseAddUpdateBindingRule(_ response: [String:JSON]) -> SRBindingRuleDataModel? {
        guard let payload = response["payload"] else { return nil }
        return SRBindingRuleDataModel.init(param: payload)
    }
}
